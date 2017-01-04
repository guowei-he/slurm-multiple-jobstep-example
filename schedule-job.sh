#!/bin/bash
#SBATCH -p parallel
# Set number of tasks to run
#SBATCH --ntasks=56
# Set number of cores per task (default is 1)
#SBATCH --cpus-per-task=1
# Walltime format hh:mm:ss
#SBATCH --time=00:30:00
# Output and error files
#SBATCH -o job.out
#SBATCH -e job.err

# **** Put all #SBATCH directives above this line! ****
# **** Otherwise they will not be in effective! ****
#
# **** Actual commands start here ****
# Load modules here (safety measure)
module purge


# First schedule a small job. Its task ID is 1. 
srun -n 12 bash task.sh 1 10 &

# Wait, then schedule a job small enough to fit in the resources. It should start immediately.
sleep 1
srun -n 12 bash task.sh 2 12 &

# Schedule a big job and 2 small jobs. Task 3 will be scheduled last due to the large resource requirement.
# Task 4 will be scheduled immediately. Task 5 will be scheduled after task 1.
sleep 1
srun -n 55 bash task.sh 3 10 &
srun -n 1 bash task.sh 4 20 &
srun -n 42 bash task.sh 5 10 &


# Wait all jobs to be finished. Otherwise Slurm will kill the job immediately.
for job in `jobs -p`
do
echo $job
    wait $job || let "FAIL+=1"
done

echo $FAIL

if [ "$FAIL" == "0" ];
then
echo "YAY!"
else
echo "FAIL! ($FAIL)"
fi
