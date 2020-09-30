### Execution Environment
DOCKER=FALSE
SINGULARITY=FALSE
# on Cluster: SINGULARITY=TRUE
TORQUE=FALSE
### Location of Files ###
# A directory with one file per tasks that specifies the execution of OUTSCRIPT
INDIR = data/conditions
# A script that fills INDIR
INSCRIPT = sim_gen_settings.R
# A directory that contains one corresponding file in OUTDIR per file in INDIR
OUTDIR = data/results
# A script that uses specifications from INDIR to generate results
OUTSCRIPT = sim_run_sim.R
# The used file extension for files in INDIR/OUTDIR
INSUFFIX = .rds
OUTSUFFIX = .rds

### Generall Computation Options ###
# Tasks is the first level of parallelisation
NTASKS = 4
# on Cluster: try e.g. NTASKS=20 or NTASKS=400
# Cores is the second level of parallelisation which OUTSCRIPT may utilise
NCORES = 1

### Docker Options ###
DFLAGS = --rm --user $(UID) -v $(CURDIR):$(DHOME) $(PROJECT)
DCMD = run
DHOME = /home/rstudio

### Singularity Options ###
SFLAGS = -H $(CURDIR):$(SHOME) $(PROJECT).sif
SCMD = run
SHOME = /home/rstudio

### qsub Options ###
WALLTIME = 0:07:00
# on Cluster: e.g WALLTIME=02:00:00 or WALLTIME=00:05:00
MEMORY = 650mb
# on Cluster: e.g. MEMORY=300mb 
QUEUE = default
QNAME = $(PROJECT) $(notdir $@)
# on Cluster: change to e.g. QNAME=ariha
QFLAGS = -d $(CURDIR) -q $(QUEUE) -l nodes=1:ppn=$(NCORES) -l walltime=$(WALLTIME) -l mem=$(MEMORY) -N "$(QNAME)"

### Automatic Options ###
PROJECT := exampletasks# CURDIR is the place where make is executed
UID = $(shell id -u)

ifeq ($(DOCKER),TRUE)
	DRUN := docker $(DCMD) $(DFLAGS)
	current_dir=/home/rstudio
endif

ifeq ($(SINGULARITY),TRUE)
	SRUN := singularity $(SCMD) $(SFLAGS)
	current_dir=/home/rstudio
endif

ifeq ($(TORQUE),TRUE)
	QRUN1 = qsub $(QFLAGS) -F "
	QRUN2 := " forward.sh
endif

RUN1 = $(QRUN1) $(SRUN) $(DRUN)
RUN2 = $(QRUN2)

all: $(INDIR) $(OUTDIR)

input: $(INDIR)

$(INDIR): $(INSCRIPT)
	$(RUN1) Rscript --vanilla $< $(NTASKS) $(RUN2)

output: $(INDIR) $(OUTDIR)
# replace the dir stem of each file in INDIR with the OUTDIR
# each file in INDIR will therefore correspond exactly to one file in OUTDIR
# these files need to exist when the variable is evaluated
# this is the reason why two runs of make are neccesary
RESULTS = $(addprefix $(OUTDIR)/, $(notdir $(wildcard $(INDIR)/*$(INSUFFIX))))
$(OUTDIR): $(RESULTS)
# since OUTDIR depends on RESULTS make searches for an implicit rule to
# generate each element in RESULTS
# this rule calls for OUTSCRIPT with the corresponding file in INDIR as argument
$(OUTDIR)/%$(OUTSUFFIX): $(INDIR)/%$(INSUFFIX)
	$(RUN1) Rscript --vanilla $(OUTSCRIPT) $< $@ $(NCORES) $(RUN2)

build: docker

docker: Dockerfile
	docker build -t $(PROJECT) $(CURDIR)

singularity: $(PROJECT).sif

$(PROJECT).sif: docker
	singularity build $@ docker-daemon://$(PROJECT):latest

reset:
	rm -rf $(OUTDIR)
	rm -rf $(INDIR)

# use `make print-anyvariable` to inspect the value of any variable
print-%: ; @echo $* = $($*)