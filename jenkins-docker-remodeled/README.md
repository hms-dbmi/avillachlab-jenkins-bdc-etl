# I think it would be easier if jenkins home was external in private repos for each.
# Things I would include in the Base. Depending how reusable our jobs are we could abstract those to another scm and organize and import them separetely.  For now we will keep track of each job per project.
# Things that we should always leave out of scm:
   *  scriptApproval.xml  <--- exposes signatures, allows for signatures to become stale.  ( i would just always approve them manually on server creation )
   *  secrets and sensitive information.
      Currently configurations for CI CD variables are stored in the config.xml and externally managed. 
   *  This remodeling will try to move to a JCasC approach using the jenkins.yaml to define environment variables.
   *  

