# Keywords : python, tree-sequence recording, tree sequence recording, SLiM, ms, tree2ms

# Input : SLiM simulation (.trees file, tree-seq recording)
# Output : sample of diploids in ms format

# Here, we could see "split_time" as the 'age of the population' or something among those lines :)

def trees2ms(id):

    # LOADING .TREE FILE #

    if selection == "sweep":
        tree = pyslim.load(str(id) + "_sweep.trees")
    elif selection == "neutral":
        tree = pyslim.load(str(id) + "_neutral.trees")

    # You could use SLiM metadata rather than end_gen variable #
    # SLiM_time = tree.metadata['SLiM']['generation'] #

    # -- SET DEMOGRAPHY -- #
    demography = msprime.Demography.from_tree_sequence(tree)
   

    # --- INITIAL EFFECTIVE SIZES OF POPULATIONS --- #
    for pop in demography.populations:
        if pop.name == 'p1':
            pop.initial_size = NeA
        else:
            pop.initial_size = NeB


    # --- SPLIT --- #
    # SPLIT TIME BETWEEN [0.1*Ne - 10.Ne] with Ne = Ne_anc #
    # split_gen is defined in SLiM and is an argument of this script #

    # ADD SPLIT TO DEMOGRAPHY
    demography.add_population_split(time=split_gen, derived = ["p1", "p2"], ancestral="pop_0")


    # --- MIGRATION --- #

    # MIGRATION TIME #
    # Happens early in backward time #
    # We want to have time for the populations to differenciate #
    mig_gen = np.random.randint(round(0.2*split_gen), round(0.5*split_gen))

    # ADD MIGRATION FROM P2 TO P1 (BACKWARD TIME) #
    # Migration IS OCCURING right now, so we set it to be actually happening
    demography.add_migration_rate_change(time=0, rate=m, source='p2', dest='p1')

    # STOP MIGRATION AT MIG_GEN #
    # Aka 'generation at which migration has started' in forward time #
    demography.add_migration_rate_change(time=mig_gen, rate=0, source='p2', dest='p1')


    # --- DEMOGRAPHIC EVENT --- #

    # DEMOGRAPHIC EVENT TIME #
    # Happens within the same timeframe than migration... #
    # Because... why not ? :x #
    #chg_time = np.random.randint(round(0.2*split_gen), round(0.5*split_gen))

    # ADD P1 SIZE CHANGE TO DEMOGRAPHY #
    demography.add_population_parameters_change(time=chg_gen, initial_size=NeB, population='p1')


    # --- SORT EVENTS --- #

    # SORT EVENTS JUST IN CASE THINGS ARE OUT OF ORDER
    demography.sort_events()

    # RECAPITATION #

    # --- RECAPITATE THE WHOLE TREE --- #
    recap_tree = pyslim.recapitate(tree, demography=demography, recombination_rate = r, random_seed = 974)

    if selection == "sweep":
        recap_tree.dump("./" + str(id) + "_sweep_recap.trees") # save the recapitated trees
    elif selection == "neutral":
        recap_tree.dump("./" + str(id) + "_neutral_recap.trees") # save the recapitated trees
    
    # check if only 1 root for all trees - else ERROR
    assert(max([t.num_roots for t in recap_tree.trees()]) == 1)

    # --- ADD NEUTRAL MUTATION --- #
    # /!\ keep=True to keep existing mutations /!\ #
    recap_mut_tree = pyslim.SlimTreeSequence(msprime.mutate(recap_tree, rate=mu, keep=True))
    recap_mut_tree.dump("./" + str(id) + "_recap_mut.trees") # save the recapitated & mutated trees

    # --- EXTRACT ONLY ALIVE INDIVIDUALS FROM POP_1 --- #
    alive = recap_tree.individuals_alive_at(0)
    populations = recap_tree.individual_populations
    alivePop1 = []

    for ind in alive :
        if populations[ind] == 1 :
            alivePop1.append(ind)

    # check if the number of alive individuals of pop_1 is correct
    assert(len(alivePop1) == NeA)

    # --- SAMPLING --- #

    # check if the number of indivicuals in pop_1 is more than samp
    assert(len(alivePop1) > samp)

    # Sample "samp" individuals from the population
    sample_inds = np.random.choice(alivePop1, samp, replace=False)

    # --- SIMPLIFICATION --- #

    # Simplify tree sequence to contain only "samp" individuals
    keep_nodes = []

    for i in sample_inds:
        keep_nodes.extend(recap_mut_tree.individual(i).nodes)

    simp_recap_mut_tree = recap_mut_tree.simplify(keep_nodes)

    # MS OUTPUT #

    # Write the ms output
    if selection == "sweep":
        ms_output = open("./" + str(id) + "_sweep.ms", "w")
    elif selection == "neutral":
        ms_output = open("./" + str(id) + "_neutral.ms", "w")

    tskit.write_ms(simp_recap_mut_tree, ms_output)
    ms_output.close()


    return()

if __name__ == '__main__' :

    import msprime, tskit, pyslim, sys
    import numpy as np

    if (len(sys.argv) != 13) :
        sys.exit("Argument missing")

    else :
        for arg in sys.argv:

            if "=" in arg :
                arg = arg.split("=")

            if arg[0] == "NeA":
                NeA = int(arg[1])

            if arg[0] == "NeB":
                NeB = int(arg[1])

            if arg[0] == "r":
                r = float(arg[1])

            if arg[0]== "mu":
                mu = float(arg[1])

            if arg[0]== "L":
                L = int(arg[1])

            if arg[0] == "m":
                m = float(arg[1])
            
            if arg[0]== "id":
                id = str(arg[1])

            if arg[0]== "samp":
                samp = int(arg[1])
            
            if arg[0]== "chg_r":
                chg_r = float(arg[1])
            
            if arg[0]== "split_gen":
                split_gen = int(arg[1])
            
            if arg[0]== "chg_gen":
                chg_gen = int(arg[1])
            
            if arg[0]== "selection":
                selection = str(arg[1])
            
    trees2ms(id)