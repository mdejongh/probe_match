#BEGIN_HEADER
#END_HEADER

'''

Module Name:
probe_match

Module Description:


'''
class probe_match:

    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    def __init__(self, config): #config contains contents of config file in hash or 
                                #None if it couldn't be found
        #BEGIN_CONSTRUCTOR
        #END_CONSTRUCTOR
        pass

    def match_probes_to_genome(self, probes, genome_id):
        # self.ctx is set by the wsgi application class
        # return variables are: matches
        #BEGIN match_probes_to_genome
        #END match_probes_to_genome

        #At some point might do deeper type checking...
        if not isinstance(matches, list):
            raise ValueError('Method match_probes_to_genome return value matches is not type list as required.')
        # return the results
        return [ matches ]
        
