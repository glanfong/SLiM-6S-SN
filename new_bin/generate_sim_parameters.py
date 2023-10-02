import argparse
import numpy as np
import string
import random
import os
from datetime import datetime

def generate_random_id():
        """Generate a random ID for the batch."""
        random_chars = random.choices(string.ascii_uppercase + string.ascii_lowercase + string.digits, k=4)
        return ''.join(random_chars)

def estimate_time_before_frequency(Ne, s, target_frequency, epsilon):
        """Compute estimate number of generations needed to reach a specified frequency."""
        assert Ne > 0, "Ne must be a positive integer"
        assert target_frequency > 0, "Frequency must be positive"
        assert target_frequency < 1, "Estimate won't work for fixation time estimation"

        generation_interval = np.arange(0, 2*Ne+1)

        firstTerm = (s / (epsilon + s))
        secondTermNumerator = Ne
        secondTermDenominator = ((1 - target_frequency)/target_frequency) * np.exp(np.float128(s) + np.float128(generation_interval)) + 1

        secondTermDenominator = ((1 - target_frequency)/target_frequency) * np.exp(np.float128(s) * np.float128(generation_interval)) + 1

        res = np.exp(- firstTerm * secondTermNumerator/secondTermDenominator)

        return res

def find_first_above_threshold(output_array, threshold):
    """
    Find the index of the first element in the output array that is higher than a set threshold.

    Parameters:
        output_array (numpy.ndarray): The output array from estimate_time_before_frequency.
        threshold (float): The threshold value to compare against.

    Returns:
        int: The index of the first element that exceeds the threshold, or -1 if none are found.
    """
    for idx, value in enumerate(output_array):
        if value > threshold:
            return idx+1
    return -1  # If no element exceeds the threshold


def generate_parameters(Ne_min, Ne_max, scenario, dip_Nr, dip_Nmu, L, samp, n_rep, migration):
        """Generate random simulation parameters based on provided ranges and scenario."""

        assert Ne_min > 0, "Ne_min must be a positive integer"
        assert Ne_max >= Ne_min, "Ne_max must be greater or equal to Ne_min"
        assert scenario in ["BTL", "CST", "EXP"], "Invalid scenario"
        assert dip_Nr > 0, "2.Nr must be a positive float"
        assert dip_Nmu > 0, "2.Nmu must be a positive float"
        assert L > 0, "L must be a positive integer"
        assert samp > 0, "samp must be a positive integer"
        assert n_rep > 0, "n_rep must be a positive integer"
        assert Ne_min > samp, "Ne_min must be greater than samp"

        # DRAW DEMOGRAPHIC PARAMTERS :
        # bigger_Ne : upper limit of population size
        # ratio_Ne_anc_over_N : ancestral population's size / current population's size
        # split_gen : generation of split ~ total evolution time
        # chg_gen : generation of demographic event
        # mig_gen : generation of migration's onset
        # SLiM_gen : Number of generation simulated in SLiM
        # NeA : population A's size after the demographic change


        NeA = 0
        while NeA < samp:
                if Ne_min == Ne_max:
                        bigger_Ne = Ne_max

                else:
                        bigger_Ne = np.random.randint(Ne_min, Ne_max)

                ratio_Nanc_over_NeA = np.random.uniform(0.02, 0.2)

                if scenario == "BTL":
                        Ne_anc = bigger_Ne
                        NeA = int(Ne_anc * ratio_Nanc_over_NeA)
                        chg_r = ratio_Nanc_over_NeA

                elif scenario == "EXP":
                        NeA = bigger_Ne
                        Ne_anc = int(NeA * ratio_Nanc_over_NeA)
                        chg_r = 1/ratio_Nanc_over_NeA

                elif scenario =="CST":
                        ratio_Nanc_over_NeA = 1
                        NeA = bigger_Ne
                        Ne_anc = bigger_Ne
                        chg_r = ratio_Nanc_over_NeA



        if migration :
                # m = 1/(10*Ne_anc)
                m = 0.1 / (2*Ne_anc)

                # m_chg = 1/(10*NeA)
                m_chg = 0.1 / (2*NeA)

        else:
                m = 0
                m_chg = 0


        # DRAW TIME PARAMETERS :
        # (unit = generations ago - backward time)
        # split_gen : generation of split ancestral pop into pop A and pop B
        # chg_gen : generation when demographic change happens
        # mig_gen : generation of onset of migration from B to A
        # SLiM_gen : number of generations simulated in SLiM

        split_gen = np.random.randint(int(0.1 * Ne_anc), int(10 * Ne_anc))
        SLiM_gen = np.random.randint(int(0.2 * split_gen), int(0.5 * split_gen))
        chg_gen = np.random.randint(int(0.2 * split_gen), int(0.5 * split_gen))
        mig_gen = np.random.randint(int(0.2 * split_gen), int(0.5 * split_gen))

        # Prevent cases where (SLiM_gen - chg_gen = 1) or (SLiM_gen - mig_gen = 1) that SLiM can't handle
        while( abs(chg_gen - SLiM_gen) < 2 or abs(mig_gen - SLiM_gen) < 2 ):
                split_gen = np.random.randint(int(0.1 * Ne_anc), int(10 * Ne_anc))
                SLiM_gen = np.random.randint(int(0.2 * split_gen), int(0.5 * split_gen))
                chg_gen = np.random.randint(int(0.2 * split_gen), int(0.5 * split_gen))
                mig_gen = np.random.randint(int(0.2 * split_gen), int(0.5 * split_gen))

        # DRAW GENETIC PARAMETERS :
        # r = average combination rate for the whole chromosome
        # mu = average neutral mutation rate

        # Compute r and mu based on 2.N.µ and 2.N.r
        mu = dip_Nmu / (2*bigger_Ne)
        r = dip_Nr / (2*bigger_Ne)

        # DRAW SELECTION COEFFICIENT :
        # selection_coefficient = random.uniform(10, 100)/(2*NeA)
        # aa = 1 / Aa = 1 + hs / AA = 1 + s 
        # with h = 0.5

        if SLiM_gen > chg_gen:
            selection_coeffcient = np.random.uniform(10, 100)/(2*Ne_anc)
        else :
            selection_coeffcient = np.random.uniform(10, 100)/(2*NeA)

        return Ne_anc, split_gen, chg_gen, mig_gen, SLiM_gen, NeA, r, mu, L, samp, n_rep, chg_r, m, m_chg, selection_coeffcient

if __name__ == "__main__":
        parser = argparse.ArgumentParser(description="Generate simulation parameters.")
        parser.add_argument("Ne_min", type=int, nargs="?", help="Minimum possible Ne value")
        parser.add_argument("Ne_max", type=int, nargs="?", help="Maximum possible Ne value")
        parser.add_argument("scenario", type=str, nargs="?", help="Scenario (BTL, CST, EXP)")
        parser.add_argument("dip_Nr", type=float, nargs="?", help="Recombination rate (expressed as 2.N.r)")
        parser.add_argument("dip_Nmu", type=float, nargs="?", help="Mutation rate (expressed as 2.N.µ)")
        parser.add_argument("L", type=int, nargs="?", help="Genome length")
        parser.add_argument("migration", type=int, nargs="?", help="Migration 0/1")
        parser.add_argument("samp", type=int, nargs="?", help="Sample size")
        parser.add_argument("n_rep", type=int, nargs="?", help="Number of replicates")

        args, _ = parser.parse_known_args()

        if args.Ne_min is None:
                Ne_min = int(input("Enter minimum Ne value: "))
        else:
                Ne_min = args.Ne_min

        if args.Ne_max is None:
                Ne_max = int(input("Enter maximum Ne value: "))
        else:
                Ne_max = args.Ne_max

        if args.scenario is None:
                scenario = input("Enter scenario (BTL, CST, EXP): ")
        else:
                scenario = args.scenario

        if args.dip_Nr is None:
                dip_Nr = float(input("Enter recombination rate (expressed as 2.N.r): "))
        else:
                dip_Nr = args.dip_Nr

        if args.dip_Nmu is None:
                dip_Nmu = float(input("Enter mutation rate (expressed as 2.N.µ): "))
        else:
                dip_Nmu = args.dip_Nmu

        if args.L is None:
                L = int(input("Enter genome length: "))
        else:
                L = args.L

        if args.migration is None:
                migration = bool(int(input("Enter migration bool (0 or 1): ")))  # Convert input to boolean
        else:
                migration = bool(args.migration)

        if args.samp is None:
                samp = int(input("Enter sample size: "))
        else:
                samp = args.samp

        if args.n_rep is None:
                n_rep = int(input("Enter number of replicates: "))
        else:
                n_rep = args.n_rep

        # Hard coded threshold
        threshold = 0.5

        # User-defined parameters for date formatting
        Y = 2 # Year format (1, 2 or 3 PhD-Year)
        MM_DD_FORMAT = "%m%d"  # Month and day format (e.g., 0829 for August 29th)

        # Get current date in the desired format
        current_date = datetime.now().strftime(f"{Y}{MM_DD_FORMAT}")

        # Generate random ID for the batch
        random_id = generate_random_id()

        # Create a directory for the batch

        if migration:
                if scenario == "CST":
                        written_scenario = "MIG"
                elif scenario == "BTL":
                        written_scenario = "MGB"
                elif scenario == "EXP":
                        written_scenario = "MGX"

        elif not migration:
                if scenario == "CST":
                        written_scenario = "CST"
                elif scenario == "BTL":
                        written_scenario = "BTL"
                elif scenario == "EXP":
                        written_scenario = "EXP"

        # Create parameters directory
        batch_dir = f"../parameters/{written_scenario}-{current_date}-{random_id}"
        os.makedirs(batch_dir, exist_ok=True)

        # Create parameters directory
        batch_log_dir = f"../logs/{written_scenario}-{current_date}-{random_id}"
        os.makedirs(batch_log_dir, exist_ok=True)

        for rep in range(1, n_rep + 1):

                # Small loop to force SLiM_gen to be above arbitrary threshold of 700 generations
                SLiM_gen = 0
                while True:
                    Ne_anc, split_gen, chg_gen, mig_gen, SLiM_gen, NeA, r, mu, L, samp, n_rep, chg_r, m, m_chg, selection_coeffcient = generate_parameters(Ne_min, Ne_max, scenario, dip_Nr, dip_Nmu, L, samp, n_rep, migration)
                    min_gen_needed = find_first_above_threshold(estimate_time_before_frequency(NeA, selection_coeffcient, 0.1, 1e-5), threshold)
                    if SLiM_gen > min_gen_needed:
                        break


                filename = f"{written_scenario}-{current_date}-{random_id}-{rep:04d}_prior_parameters.txt"
                filepath = os.path.join(batch_dir, filename)

                with open(filepath, "w") as file:
                        file.write("# Lines starting with a # will be ignored\n")
                        file.write("# id\tNe_anc\tNeA\tr\tmu\tL\tsamp\tchg_r\tsplit_gen\tchg_gen\tmig_gen\tSLiM_gen\tm\tm_chg\tselection_coefficient\n")
                        file.write(f"{written_scenario}-{current_date}-{random_id}-{rep:04d}\t{Ne_anc}\t{NeA}\t{r}\t{mu}\t{L}\t{samp}\t{chg_r:.4f}\t{split_gen}\t{chg_gen}\t{mig_gen}\t{SLiM_gen}\t{m}\t{m_chg}\t{selection_coeffcient}\n")

                print(f"Created parameter file: {filename} in {batch_dir}")
