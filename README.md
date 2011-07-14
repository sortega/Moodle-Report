Moodle-Report
=============

Moodle-Report is a set of scripts to complement Moodle for reporting some
metrics to organizations paying for online teaching (government organizations,
unions, etc).  It offers a command line utility (cli-reports directory) and a
CGI interface (cgi-reports).

Both scripts are written in Perl and require the next Perl packages:

 * Spreadsheet::WriteExcel


Command Line Utility
--------------------

First, apply the views.sql file to the database.
Then, just invoke it without arguments for the usage.

CGI Utility
-----------

First, apply the views.sql file to the database.  Copy report.cgi to a
configured CGI path ([apache docs][cgi]) and edit the file to customize the
database connection constants.  The script accepts URLs of the form:

<http://host.com/cgi-path/report.cgi?course_id=XXX>

Authentication is left to the webserver configuration, see 
[how to do it with apache][auth].

Note: read carefully the views.sql file to learn how to mark evaluations and
the end of the courses.

[auth]: http://httpd.apache.org/docs/current/howto/auth.html
[cgi]: http://httpd.apache.org/docs/2.0/howto/cgi.html
