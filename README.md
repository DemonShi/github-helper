github-helper
=============
Github-helper is a command line tool that makes it simple developing with Github.

~~~ sh
$ github-helper review gitlabhq/gitlabhq -v
~~~

Installation
------------

Dependencies:

* **Ruby 1.9.3** or newer
* **octokit 3.1.0** or newer

To install octokit, simply type in your terminal:
~~~ sh
$ gem install octokit
~~~
Please note: Ruby is required to perform this step.


Usage
------------

Most information about usage of this tool can be taken from embedded help.

To use it, simply type:

~~~ sh
$ github-helper help
~~~

To retrieve command specific help type following:

~~~ sh
$ github-helper help <command>
~~~

Running tests
------

Most of the functionality is covered by unit tests. To run them, you will need rspec 3.0 version or newer.
To run tests simply type in main folder:

~~~ sh
$ rspec
~~~

License
-------

See [LICENSE](LICENSE) file.

[Andrii Nikitiuk](http://ua.linkedin.com/pub/andrii-nikitiuk/32/609/455/) aka DemonShi
