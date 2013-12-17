# JmxClient Parser

This is a utility gem created to parse the output of [cmdline-jmxclient](http://crawler.archive.org/cmdline-jmxclient/)
into a nice, usable Ruby hash.

##Installation
Add this line to your project's Gemfile:

```
gem 'jmx_client-parser'
```

Then execute:

```
bundle install
```

Or, install it yourself with:

```
$ gem install jmx_client-parser
```

##Usage

First capture the output of cmdline-jmxclient into a string separated by newlines.  
For example:

```Ruby
# For some reason cmdline-jmxclient outputs to STDERR.
cmd_output = `java -jar ./cmdline-jmxclient.jar - 127.0.0.1:8080 java.lang:Type=Memory HeapMemoryUsage 2>&1`
```

Create a new instance:

```Ruby
parsed = JmxClient::Parser.parse(cmd_output)
```

If we assume `cmd_output` looks like:

```Bash
12/12/2013 19:11:19 +0000 org.archive.jmx.Client HeapMemoryUsage:
committed: 22429696
init: 16777216
max: 259522560
used: 14500760

12/12/2013 19:11:19 +0000 org.archive.jmx.Client NonHeapMemoryUsage:
committed: 25886720
init: 12746752
max: 100663296
used: 25679472
```

Then CmdlineJmxclientOutputParser will give us a result like:
```Ruby
{
  'HeapMemoryUsage' => {
    'committed' => '2242...',
    'init' => '167...',
    'max' => '259...',
    'used' => '145...'
  },
  'NonHeapMemoryUsage' => {
    'committed' => '258...',
    'init' => '127...',
    'max' => '100...',
    'used' => '256...'
  }
}
```

##Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
