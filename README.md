# harvestmbnewsart
Harvest Manila Bulletin for Koha Integrated Library System

This perl script lets you harvest Manila Bulletin articles into your Koha Integrated Library System (ILS) based on "date yesterday". The date for "Today's article" are actually
the date yesterday, hence the script is based on "date yesterday". Once harvesting is finished, an email will be queued in the "message_queue" table. The email will be sent to
whatever is set in the System Preference "KohaAdminEmailAddress"
This can be run in cronjob of your Koha ILS server but be sure that the following cronjobs are added before the script if it is not added in the koha-common cronjob:
- export PERL5LIB=/usr/share/koha/lib
- export KOHA_CONF=/etc/koha/sites/{instancename}/koha-conf.xml


