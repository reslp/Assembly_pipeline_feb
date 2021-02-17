rule setup_mitoflex_db:
    output: 
        ok = "bin/MitoFlex/mitoflex.db.status.ok",
    params:
        wd = os.getcwd(),
    singularity: "docker://samlmg/mitoflex:v0.2.9"
    threads: 1
    shell:
        """
        cp -pfr /MitoFlex/* bin/MitoFlex/
        cp bin/ncbi_custom.py bin/MitoFlex/ncbi.py
        cd bin/MitoFlex/
        export HOME=$(pwd)
        echo $HOME
        ./ncbi.py n
        touch {params.wd}/{output.ok}
        """

rule mitoflex:
    input:
        f = rules.subsample.output.f,
        r = rules.subsample.output.r,
        db = rules.setup_mitoflex_db.output
    output:
#        fasta = "assemblies/{assembler}/{id}/{sub}/{id}.picked.fa",
        ok = "assemblies/mitoflex/{id}/{sub}/mitoflex.ok",
#	run = directory("assemblies/{assembler}/{id}/{sub}/MitoFlex")
    params:
        wd = os.getcwd(),
	outdir = "assemblies/mitoflex/{id}/{sub}",
        id = "{id}",
        clade = get_clade,
        genetic_code = get_code 
#    resources:
#        qos="normal_binf -C binf",
#        partition="binf",
#        mem="100G",
#        ntasks="24",
#        name="MitoFlex",
#        nnode="-N 1",
    log:
        stdout = "assemblies/mitoflex/{id}/{sub}/stdout.txt",
        stderr = "assemblies/mitoflex/{id}/{sub}/stderr.txt"
    threads: 24
    singularity: "docker://samlmg/mitoflex:v0.2.9"
#    shadow: "minimal"
    shell:
        """
        cd {params.outdir}
	export HOME="{params.wd}/bin/MitoFlex"
        {params.wd}/bin/MitoFlex/MitoFlex.py all --workname MitoFlex --threads {threads} --insert-size 167 --fastq1 {params.wd}/{input.f} --fastq2 {params.wd}/{input.r} --genetic-code {params.genetic_code} --clade {params.clade} 1> {params.wd}/{log.stdout} 2> {params.wd}/{log.stderr} 
        touch {params.wd}/{output.ok}
        """
#        cp $(find ./ -name "*.picked.fa") {output.fasta}