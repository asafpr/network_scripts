#!/usr/bin/env python

"""
Translate a tf-operon network from regulonDB to a sif file. In order to link
operons to TF use the Confirmation file.
"""

import sys
import optparse
import csv
from collections import defaultdict

def process_command_line(argv):
    """
    Return a 2-tuple: (settings object, args list).
    `argv` is a list of arguments, or `None` for ``sys.argv[1:]``.
    """
    if argv is None:
        argv = sys.argv[1:]

    # initialize the parser object:
    parser = optparse.OptionParser(
        formatter=optparse.TitledHelpFormatter(width=78),
        add_help_option=None)

    # define options here:
    parser.add_option(
        '-a', '--added', action='store_true', default=False,
        help='The network is a private list of TF-sRNA')
    parser.add_option(
        '-S', '--sigma', action='store_true', default=False,
        help='The input file contains sigma-gene interactions.')
    parser.add_option(
        '-s' , '--sRNAs', action='store_true', default=False,
        help='The input file is a sRNA targets file')
    parser.add_option(
        '-R', '--RILseq', action='store_true', default=False,
        help='The input file is RILseq table.')
    parser.add_option(
        '--rilseq_EA', default='RILseq_network_interactions_EA.txt',
        help='Write the number of interactions to this file.')
    parser.add_option(
        '-o', '--operons', default = 'OperonSet.txt',
        help='File containing operons and their genes.')
    parser.add_option(
        '-c', '--conformation', default='TFSet.txt',
        help='File containing links between TF and the genes encoding them')
    parser.add_option(
        '-n', '--network', default='network_tf_operon.txt',
        help='The network file.')
    parser.add_option(
        '--noGE', default=False, action='store_true',
        help="Don't write edges generated from gene expression data.")
    parser.add_option(      # customized description; put --help last
        '-h', '--help', action='help',
        help='Show this help message and exit.')

    settings, args = parser.parse_args(argv)

    # check number of arguments, verify values, etc.:
    if args:
        parser.error('program takes no command-line arguments; '
                     '"%s" ignored.' % (args,))

    # further process settings & args if necessary

    return settings, args

def read_conf(fin):
    """
    Read the conformation file and return a dictionary with the TF as key the
    genes encoding it as value
    Arguments:
    - `fin`: An open file
    """
    tf_dict = {}
    for line in csv.reader(fin, delimiter='\t'):
        if not line or line[0].startswith('#'):
            continue
        genes = line[2]
        if genes.endswith(','):
            genes = genes[:-1]
        if not genes:
            genes = line[1][0].lower() + line[1][1:]
        tf_dict[line[1]] = [g.strip() for g in genes.split(',')]
    return tf_dict

def read_operons(fin):
    """
    Read the file with the operons and their genes and return a dictionary with
    the genes as keys and operons as values
    Arguments:
    - `fin`: The open operons file
    """
    reader = csv.reader(fin, delimiter='\t')
    reader.next()
    reader.next()
    operon_dict = {}

    for line in reader:
        if not line or line[0].startswith('#'):
            continue
        for gene in line[5].split(','):
            operon_dict[gene] = line[0].strip()
    return operon_dict

def convert_sigma(signum):
    """
    Given a sigma with a number return the name of the gene
    Arguments:
    - `signum`: The number of the sigma factor e.g. Sigma24
    """
    smap = {'Sigma19': 'fecI', 'Sigma24': 'rpoE', 'Sigma28': 'fliA',
           'Sigma32': 'rpoH' ,
           'Sigma38': 'rpoS' , 'Sigma54': 'rpoN', 'Sigma70': 'rpoD'}
    try:
        return smap[signum]
    except KeyError:
        sys.stderr.write("Can't locate %s\n"%signum)
        return None


def generate_sigma_net(sigfile, operon_dict):
    """
    Print the sigma-operon network, taken from the file, is sif format
    Arguments:
    - `sigfile`: An open network file
    - `operon_dict`: A dictionary between genes and operons
    """
    reader = csv.reader(sigfile, delimiter='\t')
    outf = csv.writer(sys.stdout, delimiter=' ')
    # Put every edge in dict before printing to avoid duplicates
    sig_dict = {}
    for line in reader:
        if not line or line[0].startswith('#'):
            continue 
        for sig in line[0].split(','):
            try:
                gname = convert_sigma(sig)
                opname = operon_dict[gname]
                tarop = operon_dict[line[1]]
            except KeyError:
                sys.stderr.write('Error in %s\n'%(str(line)))
                continue
            sig_dict.setdefault(opname, set())
            sig_dict[opname] |= set([tarop])
    for sig in sig_dict:
        for tar in sig_dict[sig]:
            outf.writerow([sig, "Sigma-operon", tar])

            
def generate_net(netfile, tf_dict, operon_dict, noGE=False):
    """
    Print a sif sormatted network of operon-operon interactions if the first
    operon contains a gene encoding a TF that regulates the second operon
    Arguments:
    - `netfile`: The input file with the TF-operon network
    - `tf_dict`: The TF-genes dictionary
    """
    # Read all the interactions and put them in a dictionary
    # As well as the operon-genes dictionary
    reader = csv.reader(netfile, delimiter='\t')
    reader.next() # First line is in special format
    outf = csv.writer(sys.stdout, delimiter=' ')
    for line in reader:
        if not line or line[0].startswith('#'):
            continue
        if noGE and line[3] == '[GEA]':
            continue
        opname = line[1].split('[')[0]
        tfname = line[0]
        try:
            tfos = [operon_dict[g] for g in tf_dict[tfname]]
#                if opname in tfos: # Remove self loops
#                    continue
        except KeyError:
            sys.stderr.write('Bad key in %s\n'%tfname)
            continue
        for tfo in tfos:
            ename = 'TF-operon-activation'
            if line[2] == '-':
                ename = 'TF-operon-repression'
            elif line[2] == '+-':
                ename = 'TF-operon-dual'
            if line[3] == '[GEA]':
                ename += '-GEA'
            outf.writerow([tfo, ename, opname])

def added_network(netfile, operon_dict, tf_dict):
    """
    Given a list of regulator and regulated adds them to the network
    Arguments:
    - `netfile`: An open file
    - `operon_dict`: A dictionary from gene to operon
    """
    for line in csv.reader(netfile, delimiter='\t'):
        tfname = line[0]
        if tfname in tf_dict:
            tfnames = tf_dict[tfname]
        else:
            tfnames = [line[0][0].lower() + line[0][1:]]
        tar = line[1][:3].lower()
        if len(line[1]) > 3:
            tar += line[1][3].upper()
        try:
            tarop = operon_dict[tar]
        except KeyError:
            sys.stderr.write('Error in %s\n'%tar)
            continue
        for tf in tfnames:
            try:
                optf = operon_dict[tf]
                print '%s Added %s'%(optf, tarop)
            except KeyError:
                sys.stderr.write('Error in operon %s\n'%line[0])
                continue


def read_RILseq(rsfile, operon_dict, na_file=None):
    """
    Read RIL-seq file and write the results as a sif network. Translate genes
    to operons. In the case of AS, IGRs and 3'UTRs, generate new nodes.
    Treat 5'UTRs as part of the gene and IGT as part of the operon.
    The network in indirected
    Arguments:
    - `rsfile`: RILseq results table
    - `operon_dict`: A dictionary between gene and operon
    - `na_file`: Write the number of interactions to this file
    """
    def gtoent(g):
        """
        Translate the gene name to entity, wither new entity (in the case of
        AS, IGR and 3'UTR) or operon
        Arguments:
        - `g`: gene name
        """
        spl = g.split('.')
        if spl[-1] in ('AS', 'IGR', '3UTR', 'EST3UTR'):
            return g
        if spl[-1].endswith('5UTR'):
            return gtoent(spl[0])
        if spl[-1] == 'IGT':
            g = spl[0]
        try:
            return operon_dict[g]
        except KeyError:
            sys.stderr.write("Can't find operon for %s\n"%g)
            return g

    incsv = csv.DictReader(open(rsfile), delimiter='\t')
    # Remove duplicates using this set
    written = defaultdict(int)
    for row in incsv:
        g1 = row['RNA1 name']
        g2 = row['RNA2 name']
        op1 = gtoent(g1)
        op2 = gtoent(g2)
        if (op1, op2) not in written and (op2, op1) not in written:
            print "%s RILseq %s"%(op1, op2)
        if (op2, op1) in written:
            written[(op2, op1)] += int(row['interactions'])
        else:
            written[(op1, op2)] += int(row['interactions'])
    if na_file:
        for k, v in written.items():
            na_file.write("%s (RILseq) %s\t%d\n"%(k[0], k[1], v))
        


def sRNA_network(
    fin, operon_dict,
    is_tar=['known binding', 'reliable', 'known binding positive']):
    """
    Read the all_targets file and print the interactions between sRNA and
    an operon
    Arguments:
    - `fin`: The file with all the sRNA targets
    - `operon_dict`: A dictionary to link gene to an operon
    - `is_tar`: What considers a target
    """
    fout = csv.writer(sys.stdout, delimiter=' ')
    for line in csv.reader(fin, delimiter='\t'):
        if line[2] in is_tar:
            srname = line[0][0].lower() + line[0][1:]
            try:
                gname = line[1][0].lower() + line[1][1:]
                op_name = operon_dict[gname]
            except KeyError:
                sys.stderr.write("Can't find operon for %s\n"%line[1])
                continue
            ename = 'sRNA-regulation'
            if 'positive' in line[2]:
                ename += '-positive'
            fout.writerow([srname, ename, op_name])
    

def main(argv=None):
    settings, args = process_command_line(argv)
    operon_dict = read_operons(open(settings.operons, 'rb'))
    if settings.sigma:
        generate_sigma_net(open(settings.network, 'rb'), operon_dict)
        return 0
    if settings.sRNAs:
        sRNA_network(open(settings.network, 'rb'), operon_dict)
        return 0
    if settings.RILseq:
        with open(settings.rilseq_EA, 'w') as rea:
            read_RILseq(settings.network, operon_dict, rea)
        return 0
    tf_dict = read_conf(open(settings.conformation, 'rb'))
    if settings.added:
        added_network(open(settings.network), operon_dict, tf_dict)
        return 0           
    generate_net(
        open(settings.network, 'rb'), tf_dict, operon_dict, noGE=settings.noGE)
    return 0        # success

if __name__ == '__main__':
    status = main()
    sys.exit(status)
