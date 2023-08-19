# Replicating the Results of "Superiorization as a novel strategy for linearly constrained inverse radiotherapy treatment planning"
Scripts to reproduce results from "Superiorization as a novel strategy for linearly constrained inverse radiotherapy treatment planning" (arxiv:2207.13187)

## Prerequisites

Before you begin, ensure you have met the following requirements:

- [Git](https://git-scm.com/downloads): Install Git on your machine.
- [MATLAB](https://www.mathworks.com/products/matlab.html): MATLAB is required to run the code.

## Reproducing the Results

To replicate the results of our paper, follow these steps:

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/e0404/paper-superiorization-imrt.git
   ```

2. Change your current directory to the repository:

   ```bash
   cd paper-superiorization-imrt
   ```

3. Initialize and update submodules:

   ```bash
   git submodule init
   git submodule update
   ```

4. Start MATLAB.

5. Navigate into the `matRad` submodule:

   ```matlab
   cd matRad
   ```

6. Run the `matRad_rc` script to set up the matRad radiotherapy planning tool:

   ```matlab
   matRad_rc
   ```

7. Prepare the dataset by running the following scripts from the `scripts` folder:
   - `Prepare_HN.m` for the Head and Neck dataset.
   - `Prepare_prostate.m` for the Prostate dataset.
   - `Prepare_TG119.m` for the TG119 dataset.


8. To reproduce the figures from the paper run the following scripts:
   - `Figure_1.m` to produce all subplots of Figure 1.
   - `Figure_2_1.m` to produce all subplots of Figure 3 and Figure 2, treatment plan I.
   - `Figure_2_2.m` to produce all subplots of Figure 2, treatment plan II.
   - `Figure_2_3.m` to produce all subplots of Figure 2, treatment plan III.
   - `Figure_4_5_HN.m` to produce all subplots of Figures 4 and 5.
   - `Figure_6_prostate.m` to produce all subplots of Figure 6.


## Directory Structure

The repository is organized as follows:

- `matRad/`: Submodule containing the matRad radiotherapy planning tool.
- `scripts/`: Contains scripts and functions to reproduce all figures from the paper.

## Citing the Paper

If you use the code or replicate the results for your research, please consider citing our paper:

```
@misc{barkmann2022superiorization,
      title={Superiorization as a novel strategy for linearly constrained inverse radiotherapy treatment planning}, 
      author={Florian Barkmann and Yair Censor and Niklas Wahl},
      year={2022},
      eprint={2207.13187},
      archivePrefix={arXiv},
      primaryClass={physics.med-ph}
}
```

## Issues and Contributions

If you encounter any issues while replicating the results or have suggestions for improvements, please open an issue in this repository. We welcome contributions from the community to enhance and extend the provided codebase.

