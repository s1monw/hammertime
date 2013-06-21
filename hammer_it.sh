#####################################################################################
#  ___ ___                                       ___________.__                
# /   |   \_____    _____   _____   ___________  \__    ___/|__| _____   ____  
#/    ~    \__  \  /     \ /     \_/ __ \_  __ \   |    |   |  |/     \_/ __ \ 
#\    Y    // __ \|  Y Y  \  Y Y  \  ___/|  | \/   |    |   |  |  Y Y  \  ___/ 
# \___|_  /(____  /__|_|  /__|_|  /\___  >__|      |____|   |__|__|_|  /\___  >
#
# With a Hammer in your Hand... ElasticSearch
#####################################################################################


#####################################################################################
# No Slides -  No Bullshit!!
# http://www.github.com/s1monw/hammertime
#####################################################################################

# Run the setup...
#./bin/setup.sh

# Let's fire up a node and see what happens
# This really only starts an ES node by running ./elasticsearch/bin/elasticsearch
# plus some sugar... go check it out...
# Note: this starts nodes with a clustername set to the output of `whoami` to prevent
# fetching your neighbors data!
./bin/fireupNode.sh mc-hammer

# "Is it running?"
curl -s -XGET 'http://localhost:9200?pretty=true'


#####################################################################################
# How do I get data in?
# ElasticSearch by default takes any json and "tries to do the right thing"
#####################################################################################

curl -s -XPUT 'http://localhost:9200/hacker_index/hacker/1?pretty=true' -d '{
  "name" : "Simon Willnauer",
  "profession" : [ "Co-Founder & Lucene Hacker @ ElasticSearch",
                   "Lucene Core Committer since 2006 and PMC Member"],
  "passion" : "Information Retrieval, NLP, Machine Learning, Concurrency",
  "freetime" : "Runner, Swimmer, Father & Berlin Buzzwords Co-Organizer",
  "twitter" : "https://www.twitter.com/s1m0nw",
  "github" : "http://www.github.com/s1monw/",
  "company" : "http://elasticsearch.com/about/careers/"
}'


# Is it there? - NoSQL you know! 
# This operation is RealTime... "did he say realtime?" ;)
curl -s -XGET 'localhost:9200/hacker_index/hacker/1?pretty=true' 

# Or just search - Lucene you know! 
# This operation is NearRealTime ~1 second default delay
curl -s -XGET 'localhost:9200/hacker_index/_search?q=simon&pretty=true'

# Looks pretty manual doesn't it...?

#####################################################################################
# Let's get started and create an index and push some real data in
#####################################################################################
# Let's fire up another node. 
./bin/fireupNode.sh ice-t

# Check which Nodes are running
curl -s -XGET 'http://localhost:9200/_cluster/nodes/stats?pretty=true' 

# Ok lets move on and use some tools - tries to read from localhost:9200
open http://karmi.github.com/elasticsearch-paramedic/

# Start indexing twitter
# curl -s -O download.elasticsearch.org/stream2es/stream2es; chmod +x stream2es
# visit https://github.com/elasticsearch/stream2es for how to setup twitter streaming with OAuth
./bin/stream2es twitter 

# this will index tweets similar to this one:
curl -s -XPUT 'http://localhost:9200/twitter/status/xXx?pretty=true' -d '
{
   "_id":"xXx",
   "user":{
      "screen-name":"simonw",
      "name":"simon willnauer",
      "created_at":"Wed Jun 18 16:04:28 +0000 2013",
      "id":214497014
   },
   "text":"Hey Hey Xing ;)",
   "created_at":"Wed Jun 19 16:04:28 +0000 2013"
}'

# Backup for no internet connection... 
# just push the raw data into ElasticSearch
# cat raw_data.json | bin/stream2es stdin -i twitter -t status

# Check Paramedic again
open http://karmi.github.com/elasticsearch-paramedic/

# what's happening? No Schema?
# ElasticSearch deploys a default schema based on your data!
curl -s -XGET 'http://localhost:9200/twitter/_mapping?pretty=true'

# Dude, some redundancy would be awesome!
# Scale out replicas dynamically!
curl -s -XPUT 'localhost:9200/twitter/_settings' -d '{
    "index" : {
        "number_of_replicas" : 1,
        "refresh_interval" : "1s"
    }
}'

# Check Paramedic again
open http://karmi.github.com/elasticsearch-paramedic/

# Awesome now we have replicas and indexed some data lets move on and add another node
./bin/fireupNode.sh snoop

# Check Paramedic again
open http://karmi.github.com/elasticsearch-paramedic/


#####################################################################################
# Let start searching some data
# Note: some of the queries might not return anything since we indexed
# live data from twitter - try plying with them.
#####################################################################################

# Perfect let's explore the data we have so far....
curl -s -XGET 'http://localhost:9200/twitter/_search?pretty=true'

# gimme everything with country = United States
curl -s -XPOST 'localhost:9200/twitter/_search?pretty=true' -d '{
    "query": { 
        "filtered" : {
            "query" : {
                "match_all": {} 
            },
            "filter" : {
                "query": {
                  "match": {
                     "place.country" : {
                        "query" : "United States",
                        "operator" : "and"
                     }
                  }
                }
            }
        }
    }
}
'

# a simple match query on field 'text' - you might wanna change the query :)
curl -s -XPOST 'localhost:9200/twitter/_search?pretty=true' -d '{
    "query": { 
        "filtered" : {
            "query" : {
                "match": { "text" : "LOL" } 
            },
            "filter" : {
                "query": {
                  "match": {
                     "place.country" : {
                        "query" : "United States",
                        "operator" : "and"
                     }
                  }
                }
            }
        }
    }
}'

# with common terms query 
curl -s -XGET 'localhost:9200/twitter/_search?pretty=true' -d '{
    "query": { 
        "filtered" : {
            "query" : {
                "match": { 
                    "text" :  {
                        "query" : "this is",
                        "cutoff_frequency" : 0.01
                    }
                } 
            },
            "filter" : {
                "query": {
                  "match": {
                     "place.country" : {
                        "query" : "United States",
                        "operator" : "and"
                     }
                  }
                }
            }
        }
    }
}'

# or do "Search As You Type" / Query Suggestions
curl -s -XPOST 'localhost:9200/twitter/_search?pretty=true' -d '{
    "query": { 
        "match_phrase_prefix": { 
            "user.name" : "simon willn"
        }
    },
    "facets": {
       "user_handles": {
          "terms": {
            "field" : "user.screen-name",
            "size" : 10
          }
       }
    }
}'

# find active countries and get the total counts...
curl -s -XPOST 'localhost:9200/twitter/_search?search_type=count&pretty=true' -d '{
    "query": { 
        "constant_score": {
           "filter": {
               "range" : {
                    "created_at" : { 
                        "from" : "now-10d", 
                        "to" : "now", 
                        "include_lower" : true, 
                        "include_upper": false
                    }           
                }
            }
        } 
    },
    "facets": {
       "active_countries": {
          "terms": {
            "field" : "place.country_code",
            "size" : 10
          }
       }
    }
}'

#####################################################################################
# OK awesome but why do we have to use the country code? - We can facet on the country
# keyword, no?
#
#####################################################################################

curl -s -XPOST 'localhost:9200/twitter/_search?search_type=count&pretty=true' -d '{
    "query": { 
        "constant_score": {
           "filter": {
               "range" : {
                    "created_at" : { 
                        "from" : "now-10d", 
                        "to" : "now", 
                        "include_lower" : true, 
                        "include_upper": false
                    }           
                }
            }
        } 
    },
    "facets": {
       "active_countries": {
          "terms": {
            "field" : "place.country.keyword",
            "size" : 10
          }
       }
    }
}'

#####################################################################################
# So what can I do with it?
# Lets take this into something real...
#####################################################################################

# Download Kibana 

git clone git@github.com:elasticsearch/kibana.git
open kibana/index.html

# Once you are done load the dashboard.json file contained in the current folder via the UI
# and see the magic :) - enjoy!

#####################################################################################
# This was pretty awesome but what if your data grows beyond the shards you have?
#####################################################################################

# Create yet another index
curl -s -XPUT 'http://localhost:9200/twitter_ng/'
  
# start indexing again
./bin/stream2es twitter -i twitter_ng

# Or use the backup data
#cat raw_data.json | bin/stream2es stdin -i twitter_ng -t status

# Make sure we can see the data...
curl -s -XGET 'http://localhost:9200/twitter,twitter_ng/_refresh?pretty=true'

# Now you can simply search across both indices as it would be a single one
curl -s -XGET 'http://localhost:9200/twitter,twitter_ng/_search?pretty=true'

# If you don't want to expose all those names and make URLs more complex you can use
# and alias....
curl -s -XPOST 'http://localhost:9200/_aliases' -d '{
    "actions" : [
        { "add" : { "index" : "twitter", "alias" : "twitter_production" } },
        { "add" : { "index" : "twitter_ng", "alias" : "twitter_production" } }
    ]
}' 


# Or give folks convenience access here
curl -s -XPOST 'http://localhost:9200/_aliases' -d '{
    "actions" : [
        { "add" : { "index" : "twitter",
                    "alias" : "twitter_us_only", 
                    "filter" : { "term" : { "place.country.keyword" : "United States" } } } },
        { "add" : { "index" : "twitter_ng",
                    "alias" : "twitter_us_only", 
                    "filter" : { "term" : { "place.country.keyword" : "United States" } } } }
    ]
}' 

# Now you can simply search across both indices via the alias
curl -s -XGET 'http://localhost:9200/twitter_production/_search?pretty=true'

# Or with the filter applied...
curl -s -XGET 'http://localhost:9200/twitter_us_only/_search?pretty=true'

#####################################################################################
# Let's go back and do some maintenance...
#
# So what if we need to shut down one of the node for maintenance
# Lets decommission node "snoop" but first move all shards away from this node
#####################################################################################

# ok lets flush all RAM buffers to disk and empty transaction logs before we shut down
curl -s -XGET 'localhost:9200/twitter_production/_flush'

curl -s -XPUT 'localhost:9200/twitter_production,hacker_index/_settings?pretty=true' -d '{
    "index.routing.allocation.exclude.name" : "snoop"
}'

# Check paramedic
open http://karmi.github.com/elasticsearch-paramedic/

# now we can shut down that node
./bin/takedownNode.sh snoop



# Bring down all nodes...
./bin/takedownNode.sh ice-t
./bin/takedownNode.sh mc-hammer
./bin/takedownNode.sh busta-ryhmes


#####################################################################################
# Now it's your turn - you got all the tools you need to build something awesome!
#####################################################################################    


#####################################################################################
# /      \ |  \  |  \|        \ /      \|        \|      \ /      \ |  \  |  \ /      \ 
#|  $$$$$$\| $$  | $$| $$$$$$$$|  $$$$$$\\$$$$$$$$ \$$$$$$|  $$$$$$\| $$\ | $$|  $$$$$$\
#| $$  | $$| $$  | $$| $$__    | $$___\$$  | $$     | $$  | $$  | $$| $$$\| $$| $$___\$$
#| $$  | $$| $$  | $$| $$  \    \$$    \   | $$     | $$  | $$  | $$| $$$$\ $$ \$$    \ 
#| $$ _| $$| $$  | $$| $$$$$    _\$$$$$$\  | $$     | $$  | $$  | $$| $$\$$ $$ _\$$$$$$\
#| $$/ \ $$| $$__/ $$| $$_____ |  \__| $$  | $$    _| $$_ | $$__/ $$| $$ \$$$$|  \__| $$
# \$$ $$ $$ \$$    $$| $$     \ \$$    $$  | $$   |   $$ \ \$$    $$| $$  \$$$ \$$    $$
#  \$$$$$$\  \$$$$$$  \$$$$$$$$  \$$$$$$    \$$    \$$$$$$  \$$$$$$  \$$   \$$  \$$$$$$ 
#      \$$$        
#####################################################################################

