```
#####################################################################################
#  ___ ___                                       ___________.__                
# /   |   \_____    _____   _____   ___________  \__    ___/|__| _____   ____  
#/    ~    \__  \  /     \ /     \_/ __ \_  __ \   |    |   |  |/     \_/ __ \ 
#\    Y    // __ \|  Y Y  \  Y Y  \  ___/|  | \/   |    |   |  |  Y Y  \  ___/ 
# \___|_  /(____  /__|_|  /__|_|  /\___  >__|      |____|   |__|__|_|  /\___  >
#
# With a Hammer in your Hand... ElasticSearch
#####################################################################################
```
The ultimate `no slides no bullshit` introduction to ElasticSearch

Run 
```bash
./bin/setup.sh
```

and then go through `hammer_it.sh` and let ElasticSearch show it's potential
and awesomeness.


This introduction will make heavy use of elasticsearch tooling like [stream2es](https://github.com/elasticsearch/stream2es) 
or [kibana-dashboard](https://github.com/elasticsearch/kibana-dashboard) as well as online data fetch from twitter via your
personal twitter account. In order to go through all the examples you should have a reasonable internet connection.

Here is a [video](http://vimeo.com/66303050) of me giving this talk at NoSQL Matters in Cologne 2013. 

**NOTE:** 
 * [stream2es](https://github.com/elasticsearch/stream2es) requires a setup step in order to stream data from twitter directly. Check out the documentation from [here](https://github.com/elasticsearch/stream2es) how initally setup the tools. All you need is a working twitter account and you should be ready to go.
 * if you want to use the `bin/fetchSource.sh` script you need to have the [JQ JSON commandline tool](http://stedolan.github.com/jq/) installed
 
