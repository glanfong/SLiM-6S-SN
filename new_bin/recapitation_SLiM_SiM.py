# Keywords : python, tree-sequence recording, tree sequence recording, SLiM, ms, tree2ms

# Input : SLiM simulation (.trees file, tree-seq recording)
# Output : sample of diploids in ms format

import msprime, tskit, pyslim, sys
import numpy as np
import argparse

def tree2recapTree(tree_file, Ne_anc, NeA, r, mu, m, m_chg, SLiM_gen, mig_gen, chg_gen, split_gen, samp, mut_pos, L):

    # Important Note : Recapitation process moves backwards in time, and time is measured in units of generations ago.
    # Here, we could see "split_time" as the 'age of the population' or something among those lines :)

    # Migration : 
    # 'Destination' is the population containing the immediate ancestors of the migrants.
    # Foward in time, this is where migrants come from. Here, in reverse time, a lineage that is traced
    # backward in time (from the current day to the past) will appear to jump "into" this ancestral destination
    # at the precise time of the migration event.

    # 'Source ': the population containing the immediate descendants of the migrants. In forward time, this is
    # where migrants end up.

    # - LOADING TREES FILE - #
    tree = tskit.load(tree_file)

    # - LOAD DEMOGRAPHY FROM TREE FILE - #
    demography = msprime.Demography.from_tree_sequence(tree)

##############################################

    # - EVENT ORDER - #

    # Six cases are possible, depending on the order of the events :

    # - A : SLiM -> Migration -> Demographic change
    #   NeA at start of SLiM = Ne_anc BUT NeA at end of SLiM = Ne_anc * chg_r
    #   Backward Events : Split

    if SLiM_gen > mig_gen > chg_gen:
        event_order = "A"

    # - B : SLiM -> Demographic change -> Migration
    #   NeA at start of SLiM = Ne_anc BUT NeA at end of SLiM = Ne_anc * chg_r
    #   Backward Events : Split

    elif SLiM_gen > chg_gen > mig_gen:
        event_order = "B"

    # - C : Migration -> SLiM -> Demographic change
    #   Migration ongoing before SLiM !
    #   NeA at start of SLiM = Ne_anc BUT NeA at end of SLiM = Ne_anc * chg_r
    #   Backward Events : Migration from start of SLiM to mig_gen + Split 

    elif mig_gen > SLiM_gen > chg_gen:
        event_order = "C"

    # - D : Migration -> Demographic change -> SLiM
    #   Migration ongoing before SLiM !    
    #   NeA at start of SLiM = NeA at end of SLiM = Ne_anc * chg_r
    #   Backward Events : Migration from start of SLiM to mig_gen + Demographic change + Split

    elif mig_gen > chg_gen > SLiM_gen:
        event_order = "D"

    # - E : Demographic change -> SLiM -> Migration
    #   NeA at start of SLiM = NeA at end of SLiM = Ne_anc * chg_r
    #   Backward Events : Demographic change + Split

    elif chg_gen > SLiM_gen > mig_gen:
        event_order = "E"

    # - F : Demographic change -> Migration -> SLiM
    #   Migration ongoing before SLiM !    
    #   NeA at start of SLiM = NeA at end of SLiM = Ne_anc * chg_r
    #   Backward events : Migration from start of SLiM to mig_gen + Demographic change + Split

    elif chg_gen > mig_gen > SLiM_gen:
        event_order = "F"

    # - Unpredicted case

    else :
        raise ValueError(
            "Event Order unexpected !"
            "Please, check the demographic time parameters !"
        )

##############################################

    # - INITIAL POPULATIONS SIZES - #
    # HYPOTHESE : INITIAL SIZE = SIZE AT BEGINNING OF SLiM SIMULATIONS
    # TIMES = TIMES IN GENERATIONS AGO STARTING FROM PRESENT AKA END OF SLiM SIMULATIONS --> seems ok as it's important to ensure split older than SLiM time

    # - CHECK IF POPULATION B EXISTS -
    #   Adds p2 if needed

    if len(demography.populations) <= 2 :
        
        demography.add_population(name="p2", initial_size=Ne_anc)


    for pop in demography.populations:

        # Set p1 (population A) initial size
        if pop.name == "p1":

            # Event order such as SLiM_gen > chg_gen
            if event_order in ('A', 'B', 'C'): 
                pop.initial_size = Ne_anc

            # Event order such as chg_gen > SLiM_gen
            elif event_order in ('D', 'E', 'F'):
                pop.initial_size = NeA

        # Set p2 (and p_anc) to ancestral size
        else :
            pop.initial_size = Ne_anc

    # Sort added demography events
    demography.sort_events()
        
##############################################

    # - SPLIT - #
    demography.add_population_split(time = split_gen, derived = ["p1", "p2"], ancestral = "pop_0")

    # Sort added demography events
    demography.sort_events()

##############################################

    # - MIGRATION - #
    # Migration is from p2 to p1 in forward
    # so source = p1 and dest = p2 in backward

    # HYPOTHESE 2 : MIGRATION HAPPENS IN BACKWARD
    # Setting migration rates at time = 100 is telling "Migration happend from this point in time all the way back to all generations before"
    # So in order to say "I have migration between this and this generations", you have to tell when to "start" the migration and then
    # tell when to "stop" the migration

    # Event order such as mig_gen > SLiM_gen (migration commence avant SLiM)
    if event_order in ('C', 'D', 'F'):

        # Event order such as chg_gen > mig_gen > SLiM (Chg before Mig)
        # Migration "starts" just before SLiM with m_chg and "stops" at mig_gen
        if event_order in ('F'):
            print(f"Event order : {event_order}")
            demography.add_migration_rate_change(time = tree.metadata['SLiM']['tick'], rate = m_chg, source = 'p1', dest = 'p2')
            demography.add_migration_rate_change(time = mig_gen, rate = 0, source = 'p1', dest = 'p2')


        # Event order such as mig_gen > chg_gen > SLiM (Mig before Chg)
        # Migration "starts" just before SLiM with m_chg, change to m at chg_gen and "stops" at mig_gen
        elif event_order in ('D'):
            print(f"Event order : {event_order}")

            demography.add_migration_rate_change(time = tree.metadata['SLiM']['tick'], rate = m_chg, source = 'p1', dest = 'p2')
            demography.add_migration_rate_change(time = chg_gen, rate = m, source = 'p1', dest = 'p2')
            demography.add_migration_rate_change(time = mig_gen, rate = 0, source = 'p1', dest = 'p2')

        # Event order such as mig_gen > SLiM > chg_gen (Mig before SLiM, Chg during SLiM)
        # Migration "starts" just before SLiM with m, and "stops" at mig_gen
        elif event_order in ('C'):
            print(f"Event order : {event_order}")
            demography.add_migration_rate_change(time = tree.metadata['SLiM']['tick'], rate = m, source = 'p1', dest = 'p2')
            demography.add_migration_rate_change(time = mig_gen, rate = 0, source = 'p1', dest = 'p2')

    # Sort added demography events
    demography.sort_events()

##############################################

    # - DEMOGRAPHIC CHANGE - #

    # The "change" should be seen as backward in time
    # EXP cause population size to shrink in backward
    # BTL cause population size to increase in backward

    # Event order such as chg_gen > SLiM (Chg before SLiM)
    # p1 initial_size = NeA -> change to Ne_anc at chg_gen
    if event_order in ("D", "E", "F"):
        demography.add_population_parameters_change(time = chg_gen, initial_size = Ne_anc, population = "p1")
    
    # Sort added demography events
    demography.sort_events()

##############################################

    #  - RECAPITATION - #
    # Using the generated demography and recombination rate,
    # run coalescent simulations to complete the SLiM .trees
    # up to the MRCA (each trees must got back to a single root)

    recap_tree = pyslim.recapitate(tree, demography=demography, recombination_rate=r,
                                    random_seed=974)

    # Check if all trees have only one root
    tree_max_roots = max(t.num_roots for t in tree.trees())
    recap_max_roots = max(t.num_roots for t in recap_tree.trees())
    print(f"Maximum number of roots before recapitation: {tree_max_roots}\n"
            f"After recapitation: {recap_max_roots}")

    assert tree_max_roots >= recap_max_roots, "Recapitation must reduce number of roots"
    assert recap_max_roots == 1, "Recapitation must go back to MRCA"


##############################################

    # - SIMPLIFICATION - #
    # Get rid of unneeded samples and any extra information from them 
    # and reduce the population to the sampled individuals used for the
    # rest of the pipeline

    rng = np.random.default_rng(seed = 974)
    alive_inds = pyslim.individuals_alive_at(recap_tree, 0) # get inds alive at time = 0

    # Get nodes corresponding to the sampled individuals alive at time 0
    keep_indivs = rng.choice(alive_inds, samp, replace = False)
    keep_nodes = []
    for i in keep_indivs:
        keep_nodes.extend(recap_tree.individual(i).nodes)

    # Simplify the tree to only keep the nodes associated with the sampled individuals
    simplified_tree = recap_tree.simplify(keep_nodes, keep_input_roots = True)

    print(f"Before, there were {recap_tree.num_samples} sample nodes (and {recap_tree.num_individuals} individuals)\n"
        f"in the tree sequence, and now there are {simplified_tree.num_samples} sample nodes\n"
        f"(and {simplified_tree.num_individuals} individuals).")

##############################################

    # - ADDING NEUTRAL MUTATION - #
    # Use the msprime.sim_mutations() function, which returns a new tree sequence with additional mutations
    # to add neutral mutation to the trees.
    # Note : Need to create a RateMap to prevent mutation to occur
    # on mut_pos - if mut_pos = 0 <=> neutral so no problem

    if mut_pos == 0:
        mut_tree = msprime.sim_mutations(simplified_tree, rate = mu,
                                            model = msprime.BinaryMutationModel(),
                                            keep = True)
    else:
        rate_map=msprime.RateMap(
            position = [0, mut_pos, mut_pos+1, L],
            rate = [mu, 0, mu])
        
        mut_tree = msprime.sim_mutations(simplified_tree, rate = rate_map,
                                         model = msprime.BinaryMutationModel(),
                                         keep = True)

    print(f"The tree sequence had {simplified_tree.num_mutations} mutations before adding neutral mutations,\n"
        f"and mean pairwise nucleotide diversity is {simplified_tree.diversity():0.3e}.")

    print(f"The tree sequence now has {mut_tree.num_mutations} mutations,\n"
        f"and mean pairwise nucleotide diversity is {mut_tree.diversity():0.3e}.")

##############################################

    # - OUTPUT - #
    # Return the recapitated, simplified, mutated tree

    return (mut_tree)

##############################################

### - MAIN - ###

if __name__ == '__main__' :

    parser = argparse.ArgumentParser(description="Load simulation and tree parameters.")
    parser.add_argument("tree_file", type=str, nargs="?", help=".trees file to be recapited and for which to create a .ms file")
    parser.add_argument("Ne_anc", type=int, nargs="?", help="Ancestral population size")
    parser.add_argument("NeA", type=int, nargs="?", help="Current size of population A (after demographic change)")
    parser.add_argument("r", type=float, nargs="?", help="Recombination rate")
    parser.add_argument("mu", type=float, nargs="?", help="Mutation rate")
    parser.add_argument("m", type=float, nargs="?", help="Migration rate (before demographic change)")
    parser.add_argument("m_chg", type=float, nargs="?", help="Migration rate (after demographic change)")
    parser.add_argument("SLiM_gen", type=int, nargs="?", help="Generation at which SLiM simulation 'stops' (in backward time - generations ago)")
    parser.add_argument("mig_gen", type=int, nargs="?", help="Generation at which migration 'stops' (in backward time - generations ago)")
    parser.add_argument("chg_gen", type=int, nargs="?", help="Generation at which demographic change happens (in backward time - generations ago)")
    parser.add_argument("split_gen", type=int, nargs="?", help="Generation at which the split happens (in backward time - generations ago)")
    parser.add_argument("samp", type=int, nargs="?", help="Number of (diploid) sampled individuals")
    parser.add_argument("mut_pos", type=int, nargs="?", help="Position of beneficial mutation (sweep)")
    parser.add_argument("L", type=int, nargs="?", help="Genome length (in bp)")



    args, _ = parser.parse_known_args()

    if args.tree_file is None:
        tree_file = str(input("Enter path to .trees file to process (recapitation + creation of .ms): "))
    else:
        tree_file = args.tree_file

    if args.Ne_anc is None:
        Ne_anc = int(input("Enter Ne_anc value: "))
    else:
        Ne_anc = args.Ne_anc

    if args.NeA is None:
        NeA = int(input("Enter NeA value (pop_A size after demographic change): "))
    else:
        NeA = args.NeA

    if args.r is None:
        r = float(input("Enter recombination rate: "))
    else:
        r = args.r

    if args.mu is None:
        mu = float(input("Enter mutation rate: "))
    else:
        mu = args.mu

    if args.m is None:
        m = float(input("Enter migration rate (before demographic change): "))
    else:
        m = args.m

    if args.m_chg is None:
        m_chg = float(input("Enter migration rate (after demographic change): "))
    else:
        m_chg = args.m_chg

    if args.SLiM_gen is None:
        SLiM_gen = int(input("Enter SLiM_gen (generation at which SLiM simulation ends - backward time): "))
    else:
        SLiM_gen = args.SLiM_gen

    if args.mig_gen is None:
        mig_gen = int(input("Enter mig_gen (generation at which migration ends - backward time): "))
    else:
        mig_gen = args.mig_gen

    if args.chg_gen is None:
        chg_gen = int(input("Enter chg_gen (generation at which demographic change happens - backward time): "))
    else:
        chg_gen = args.chg_gen

    if args.split_gen is None:
        split_gen = int(input("Enter split_gen (generation at which the split happens - backward time): "))
    else:
        split_gen = args.split_gen

    if args.samp is None:
        samp = int(input("Enter number of (diploid) sampled individuals: "))
    else:
        samp = args.samp

    if args.mut_pos is None:
        mut_pos = int(input("Enter position of the beneficial mutation (sweep): "))
    else:
        mut_pos = args.mut_pos

    if args.L is None:
        L = int(input("Enter genome length (in bp): "))
    else:
        L = args.L

# - WRITE MS OUTPUT - #
# Write the information of the recapitated, simplified and mutated tree 
# to a file in ms format

mut_tree = tree2recapTree(tree_file, Ne_anc, NeA, r, mu, m, m_chg, SLiM_gen, mig_gen, chg_gen, split_gen, samp, mut_pos, L)

tree_root_name = tree_file.split(sep = "/")[-1].split(sep = ".")[0]
ms_name = tree_root_name + ".ms"

with open(ms_name, "w") as ms_file:
    tskit.write_ms(mut_tree, ms_file)

