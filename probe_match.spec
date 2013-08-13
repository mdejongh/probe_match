module probe_match {
    /* a probe has a DNA sequence, and an x and y location on the microarray */
    typedef structure {
	string probe_id;
	string probe_seq;
	int x;
	int y;
    } Probe;

    /* a match identifies the probe and the feature it matches */
    typedef structure {
	string feature_id;
	string probe_id;
    } ProbeMatch;

    /* input a list of probes, match them to the genome */
    funcdef match_probes_to_genome(list<Probe> probes, string genome_id) returns (list<ProbeMatch> matches);
};