#!/usr/bin/perl
use strict;
use warnings;


#get date today yyyy-mm-dd
#https://stackoverflow.com/questions/11020812/todays-date-in-perl-in-mm-dd-yyyy-format
use POSIX qw(strftime);

use utf8;
use Encode qw( is_utf8 );

use Time::Piece;
use Time::Seconds 'ONE_DAY';

use WWW::Curl::Easy;

use C4::Context;
our $dbh = C4::Context->dbh;

use DBI;
use HTML::Entities;

use XML::LibXML;
#use XML::Normalize::LibXML qw(trim xml_normalize xml_strip_whitespace);

use Text::Trim;

#get the dates

our @titles;

#test

my $datetoday = strftime "%Y/%m/%d", localtime;
#my $datetoday = "2020/07/20";
my $datetodayconverted = strftime "%Y%m%d", localtime;
#my $datetodayconverted = "20200720";
my $datetodayconvertedwithseconds = strftime "%Y%m%d%H%M%S", localtime;
#mydatetodayconvertedwithseconds like '20200801202833'
my $datetoday_yymmdd = substr($datetodayconverted,2);
#my $datetoday_yymmdd, August 1, 2020 will be: 200801
my $year = strftime "%Y", localtime;

my $dateyesterday = ( localtime() - ONE_DAY )->ymd('/');
#my $dateyesterday = "2020/07/20";
my $dateyesterdayconverted = ( localtime() - ONE_DAY )->ymd('');
#my $dateyesterdayconverted = "20200720";
#my $dateyesterdayconverted = "20200731";
#my $dateyesterday dash
my $dateyesterdaydash = ( localtime() - ONE_DAY )->ymd('-');
#my $dateyesterdaydash = "2020-07-20";

my $periodical = "Manila Bulletin";

my $email_from_address = C4::Context->preference('KohaAdminEmailAddress');

#my $curl=`curl http://`;

#the url for news.mb.com.ph
my $url = "https://mb.com.ph/";
my $urlcomplete = "$url"."$dateyesterday";

print $urlcomplete;


#create a directory based from date, e.g. 20200710
mkdir $dateyesterdayconverted;

#print $urlcomplete;
 
#my $curl=`curl $urlcomplete`;
#my $curl=`curl https://news.mb.com.ph/2020/06/22`;
#my $curl = `curl https://news.mb.com.ph/2020/06/22`;
#system "curl --data 'https://news.mb.com.ph/2020/06/22'";
#print $urlcomplete;

#start the curl
my $user_agent = "Mozilla/5.0 (X11; Linux i686; rv:24.0) Gecko/20140319 Firefox/24.0 Iceweasel/24.4.0";
 
my $curl = WWW::Curl::Easy->new;
 
$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_USERAGENT, $user_agent);
$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);

$curl->setopt(CURLOPT_URL, $urlcomplete);

 
# A filehandle, reference to a scalar or reference to a typeglob can be used here.
my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
 
# Starts the actual request
my $retcode = $curl->perform;
 
# Looking at the results...
if ($retcode == 0) {
#       print("Transfer went ok\n");
	#mkdir $datetodayconverted;
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
      # print("Received response: $response_body\n");
	#get the number of pages
  my $curledurldatecomplete = $response_body;
	#our ($numberofpages) = $curledurldatecomplete =~ /<i class=\"mb-icon-arrow-right\">.*?last.*?>(\d+)<\/a>/m;
  our ($numberofpages) = $curledurldatecomplete =~ /<a class=\"last\".*?page\/(\d+)\/\"/m;
  #<a class="last" href="https://mb.com.ph/2020/07/20/page/11/">11</a>
#	print $var1;
#	print $numberofpages;

#	for ( $a = 1; $a <= $numberofpages; $a++ )
#{
#       print("$urlcomplete".'/page/'."$numberofpages");
#}

#print $curledurldatecomplete;
print $numberofpages;

	my @array = (1..$numberofpages);
	my $i = "";
	foreach $i (@array) {
		#print "$urlcomplete".'/page/'."$i\n";
#		system (curl "$urlcomplete".'/page/'."$i");
#		`curl "$urlcomplete".'/page/'."$i"`;
##		$_++;
		#print "$urlcomplete".'/page/'."@array\n";
		my $pagetodownload = "$urlcomplete".'/page/'."$i";		
		#print $pagetodownload;

		my $user_agent = "Mozilla/5.0 (X11; Linux i686; rv:24.0) Gecko/20140319 Firefox/24.0 Iceweasel/24.4.0";
		my $curl = WWW::Curl::Easy->new;

		$curl->setopt(CURLOPT_HEADER,1);
		$curl->setopt(CURLOPT_USERAGENT, $user_agent);
		$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);

		$curl->setopt(CURLOPT_URL, "$pagetodownload");

		# A filehandle, reference to a scalar or reference to a typeglob can be used here.
		my $response_body;
		$curl->setopt(CURLOPT_WRITEDATA,\$response_body);

		# Starts the actual request
		my $retcode = $curl->perform;

		# Looking at the results...
		if ($retcode == 0) {
		#       print("Transfer went ok\n");
	        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        	# judge result and next action based on $response_code
	 #      print("Received response: $response_body\n");
	       
	 #	Removed just to test opening the file and search from it     
        	#my $filename = "$datetodayconverted".'/'."$datetodayconverted".'page_'."$i".'.html';
	        #open my $fh, ">", $filename or die("Could not open file. $!");
        	#print $fh $response_body;
	        #close $fh;
	 # --end Removed just..
	 		 #our ($pages) = $response_body =~ /<article id=\".+data-permalink=\"(.*?)>/s;
                foreach ($response_body =~ /<h4 class=\"title\"><a href=\"(.*?)\">/g) {
		my $filename = "$dateyesterdayconverted".'/list.txt';
                open my $fh, '>>', $filename or die("Could not open file. $!");                		
                print $fh "$_\n";
                close $fh;
}                 
}
#		print "$urlcomplete".'/page/'."@array\n";
#print "All done: $i\n";

#	my @array = (1,3,5,7,9);
#my $i="Hello there";
#foreach $i (@array) {
#	print "This element: $i\n";
#}
}
	

} else {
        # Error code, type of error, error message
        print("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
}


#print $curl;
#print $retcode;

#Get the number of pages by assigning the match group to the last digit in the pagination
#https://stackoverflow.com/questions/23967146/perl-assign-regex-match-groups-to-variables
#my ($numberofpages) = $curledurldatecomplete =~ /<ul class=\"uk-pagination\">.+<\/a.*?>(\d+)<\/a>.*?.<\/a>.*?<\/ul>/s;
#print $var1;
#print my $numberofpages;

#$numberofpages =~ s|/<ul class=\"uk-pagination\">.+<\/a.*?>(\d+)<\/a>.*?.<\/a>.*?<\/ul>/|

my $filestoprocess = "$dateyesterdayconverted".'/list.txt';

open(my $fh, '<:encoding(UTF-8)', $filestoprocess)
  or die "Could not open file '$filestoprocess' $!";

while (my $row = <$fh>) {
  chomp $row;
  #print "Processing $row";


my $user_agent = "Mozilla/5.0 (X11; Linux i686; rv:24.0) Gecko/20140319 Firefox/24.0 Iceweasel/24.4.0";

my $curl = WWW::Curl::Easy->new;

$curl->setopt(CURLOPT_HEADER,1);
#$curl->setopt(CURLOPT_RETURNTRANSFER, 1);
$curl->setopt(CURLOPT_USERAGENT, $user_agent);
$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
#so that our curl does not return any garbage
$curl->setopt(CURLOPT_ENCODING,"");

$curl->setopt(CURLOPT_URL, $row);


# A filehandle, reference to a scalar or reference to a typeglob can be used here.
my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);

# Starts the actual request
my $retcode = $curl->perform;

# Looking at the results...
if ($retcode == 0) {
#       print("Transfer went ok\n");
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
      # print("Received response: $response_body\n");
        my $curledarticle = $response_body;
        #our ($numberofpages) = $curledurldatecomplete =~ /<ul class=\"uk-pagination\">.+<\/a.*?>(\d+)<\/a>.*?.<\/a>.*?<\/ul>$
        our ($art_title) = $curledarticle =~ /<meta property=\"og:title\" content=\"(.*?)" \/>/s;
        our ($art_author) = $curledarticle =~ /<p class=\"author\">.*?<span>by<\/span> (.*?)<\/p>/s;
        our ($art_date) = $curledarticle =~ /<script type=\"application\/ld.*?\"datePublished\":\"(.*?)T/s;
        our ($art_fulltext) = $curledarticle =~ /<section class=\"article-content\">(.*?)<\/section>/s;
        #$art_fulltext =~ s/<p>//g;
        #$art_fulltext =~ s/<\/p>//g;
        #$art_fulltext =~ s/<\/p>//g;   
    
        #$art_author =~ s/<\/a>//g;
        
        #my $article_metadata = "$art_title" . '||' . "$art_author" . '||' . "$art_date" . '||' . "$art_fulltext" . '\n';

        #foreach ($response_body =~ /<article id=\".+data-permalink=\"(.*?)\">/g) {
        #my $filename = "$datetodayconverted".'/list.txt';
# my $filename = "20200627/artlist.txt";
 #      open my $fh, '>>', $filename or die("Could not open file. $!");
 

#$dbh->do('SET NAMES utf8mb4')
 #  or die($dbh->errstr);

#$dbh->{mysql_enable_utf8mb4} = 1;

  #utf8::decode($art_title);
  #utf8::decode($art_fulltext);
  decode_entities($art_title);
  #decode_entities($art_fulltext);

      if (defined $art_author) {
          $art_author =~ s/<\/a>//g;
          } else {
                my $filename = "$dateyesterdayconverted".'/error.txt';
                open my $fh, '>>', $filename or die("Could not open file. $!");                   
                print "Error processing biblio_author".$fh."$_\n";
               close $fh;

                $art_author = "1";
          }



  #$dbh->do("INSERT INTO `biblio` (`author`,`title`,`datecreated`,`abstract`) VALUES ('$art_author','$art_title','$datetodayconverted','$art_fulltext')");
  my $sth_biblio;
  $sth_biblio = $dbh->prepare("INSERT INTO `biblio` (`author`,`title`,`datecreated`,`abstract`) VALUES (?,?,?,?)");
  $sth_biblio->execute($art_author,$art_title,$datetodayconverted,$art_fulltext);
 



  #my $number = 1;
  #get the highest biblionumber
  my @params = "";
  my $highestbiblionumber = $dbh->selectrow_array('SELECT biblionumber FROM biblio ORDER BY biblionumber DESC LIMIT 0,1');
  #my $sth = $dbh->prepare($query);
# my $out = $dbh->execute() or die "Unable to execute sql: $dbh->errstr";
  #$sth->execute();
# my $highestnumber = $sth->fetchrow_hashref();
  

  #$dbh->execute();
  $dbh->do("INSERT INTO `biblioitems` (`biblionumber`,`itemtype`,`url`) VALUES ('$highestbiblionumber','ART','$row')");   
# print $highestnumber;
  #      print $fh "$article_metadata";
#        close $fh;


        my $doc = XML::LibXML::Document->new('1.0','UTF-8');

        my $schemalocation = 'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd';
       
        my $root = $doc->createElement('record');
        #my $root = $doc->createElementNS( 'http://www.w3.org/2001/XMLSchema-instance', 'record' );
        #$root->setNamespace('http://www.w3.org/2001/XMLSchema-instance','xsi',0);
        #my $node = $doc->createElementNS('http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd','schemaLocation');

        #$root->setNamespace('http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd','schemaLocation',0);
        #$root->setNamespace('http://www.loc.gov/MARC21/slim');
        $root->setNamespace('http://www.w3.org/2001/XMLSchema-instance','xsi',0);
        $root->setAttribute('xsi:schemaLocation',$schemalocation);
        $root->setAttribute('xmlns','http://www.loc.gov/MARC21/slim');

#$root->setNamespace(
        #$doc->setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
        $doc->setDocumentElement($root);

        my $leader = $doc->createElement('leader');
        $root->appendChild($leader);
        $leader->appendText('00927nam a2200241Ia 4500');

        my $controlfield008 = $doc->createElement('controlfield');
        $root->appendChild($controlfield008);
        $controlfield008->setAttribute('tag','008');
        $controlfield008->appendText("$datetoday_yymmdd".'s'."$year".'    ph ||||| |||| 00| 0 eng d');


               if (defined $art_author) {
          
        my $datafield100 = $doc->createElement('datafield');
        $root->appendChild($datafield100);
        $datafield100->setAttribute('tag','100');
        $datafield100->setAttribute('ind1','0');
        $datafield100->setAttribute('ind2',' ');
        my $subfield100a = $doc->createElement('subfield');
        $datafield100->appendChild($subfield100a);
        $subfield100a->setAttribute('code','a');
        $subfield100a->appendText("$art_author");
        }
          else
          {
                my $filename = "$dateyesterdayconverted".'/error.txt';
                open my $fh, '>>', $filename or die("Could not open file. $!");                   
                print "Error processing 100a".$fh."$_\n";
               close $fh;

                $art_author = "1";

          }



        my $datafield245 = $doc->createElement('datafield');
        $root->appendChild($datafield245);
        $datafield245->setAttribute('tag','245');
        $datafield245->setAttribute('ind1',' ');
        $datafield245->setAttribute('ind2',' ');
        my $subfield245a = $doc->createElement('subfield');
        $datafield245->appendChild($subfield245a);
        $subfield245a->setAttribute('code','a');
        $subfield245a->appendText("$art_title"." /");

        if (defined $art_author){ 
        my $subfield245c = $doc->createElement('subfield');
        $datafield245->appendChild($subfield245c);
        $subfield245c->setAttribute('code','c');
        $subfield245c->appendText("$art_author");
        } else {
                my $filename = "$dateyesterdayconverted".'/error.txt';
                open my $fh, '>>', $filename or die("Could not open file. $!");                   
                print "Error processing 245c".$fh."$_\n";
               close $fh;

                $art_author = "1";

        }

        my $datafield490 = $doc->createElement('datafield');
        $root->appendChild($datafield490);
        $datafield490->setAttribute('tag','490');
        $datafield490->setAttribute('ind1',' ');
        $datafield490->setAttribute('ind2',' ');
        my $subfield490a = $doc->createElement('subfield');
        $datafield490->appendChild($subfield490a);
        $subfield490a->setAttribute('code','a');
        $subfield490a->appendText("$periodical".' ; '."$dateyesterdaydash".'.');


        if(defined $art_fulltext){
          decode_entities($art_fulltext);
        $art_fulltext =~ s/<div.*?>.*?<\/div>//g;
        $art_fulltext =~ s/<div.*?>//g;
        $art_fulltext =~ s/<a href.*?>.*?<\/a>//g;
        $art_fulltext =~ s/<script type.*?>//g;
        $art_fulltext =~ s/<figure class.*?<\/figure>//g;
        $art_fulltext =~ s/<figure.*?>//g;
        $art_fulltext =~ s/<figure.*?>//g;
        $art_fulltext =~ s/<\w+>//g;
        $art_fulltext =~ s/<\/\w+>//sg;
        $art_fulltext =~ s/<\n\n\n>//g;
        $art_fulltext =~ s/&nbsp;//g;
        #$art_fulltext =~ s/â/"/g;
        #$art_fulltext =~ s/”/"/g;
        $art_fulltext =~ s/[ \f\t\v]$//g;

        my $datafield520 = $doc->createElement('datafield');
        $root->appendChild($datafield520);
        $datafield520->setAttribute('tag','520');
        $datafield520->setAttribute('ind1',' ');
        $datafield520->setAttribute('ind2',' ');
        my $subfield520a = $doc->createElement('subfield');
        $datafield520->appendChild($subfield520a);
        $subfield520a->setAttribute('code','a');
        #use below if XML::Normalize::LibXML is installed
        #xml_strip_element($subfield520a->appendText($art_fulltext));
        $subfield520a->appendText(trim($art_fulltext));

        } else {
                my $filename = "$dateyesterdayconverted".'/error.txt';
                open my $fh, '>>', $filename or die("Could not open file. $!");                   
                print "Error processing 520a".$fh."$_\n";
                close $fh;

                $art_fulltext = "1";
        }


        my $datafield999 = $doc->createElement('datafield');
        $root->appendChild($datafield999);
        $datafield999->setAttribute('tag','999');
        $datafield999->setAttribute('ind1',' ');
        $datafield999->setAttribute('ind2',' ');
        my $subfield999c = $doc->createElement('subfield');     
        $datafield999->appendChild($subfield999c);
        $subfield999c->setAttribute('code','c');  
        $subfield999c->appendText("$highestbiblionumber");
        my $subfield999d = $doc->createElement('subfield');
        $datafield999->appendChild($subfield999d);
        $subfield999d->setAttribute('code','d');  
        $subfield999d->appendText("$highestbiblionumber");

        #my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
        #$pp->pretty_print($doc); # modified in-place
        my $format = 2;

        my $metadata = $doc->toString($format);


  #my $metadata = $marcprepend01.$datetodayconvertedwithseconds.'.0'.$marcprepend02.$datetoday_yymmdd.'s'.$year.$marcprepend03.
  #"<\/controlfield>\n".$marcprepend_datafieldtag100.$art_author.'</subfield>'.$marcappend_datafield.$marcprepend_245.$art_title.
  #" \/ <\/subfield>\n    <subfield code=\"c\">by ".$art_author.'.'.$marcappend.$marcprepend_490.'Manila Bulletin ; '.$art_date.'.'.$marcappend.
  #$marcprepend_520."$art_fulltext".$marcappend_520.$marcprepend_856.$row.$marcappend.$marcprepend_999c.$highestbiblionumber.$marcprepend_999d.
  #$highestbiblionumber.$marcappend.$marcend;
  #my $metadata_utf8 = utf::encode($metadata);
  #utf8::encode($metadata);
  #$dbh->do( "set names utf8" );

$dbh->do('SET NAMES utf8mb4')
   or die($dbh->errstr);

$dbh->{mysql_enable_utf8mb4} = 1;

  
  #$dbh->do("INSERT INTO `biblio_metadata` (`biblionumber`,`format`,`schema`,`metadata`) VALUES ('$highestbiblionumber','marcxml','MARC21','$metadata')");
  my $sth = $dbh->prepare("INSERT INTO `biblio_metadata` (`biblionumber`,`format`,`schema`,`metadata`) VALUES (?,?,?,?)");
  $sth->execute($highestbiblionumber,'marcxml','MARC21',$metadata);
#  $sth->execute();

  $dbh->do("INSERT INTO `zebraqueue` (`biblio_auth_number`,`operation`,`server`,`done`) VALUES ('$highestbiblionumber','specialUpdate','biblioserver','0')");   
#print $art_fulltext;

  my $sth_actionlog;
  $sth_actionlog = $dbh->prepare("INSERT INTO `action_logs`(`user`, `module`, `action`, `object`, `info`, `interface`) VALUES ('0','CATALOGUING','ADD',?,
    'biblio','cron')");
  $sth_actionlog->execute($highestbiblionumber);


#print is_utf8($art_fulltext) ? 'characters' : 'bytes';

    my $filename_biblio = "$dateyesterdayconverted".'/list_biblionumber.txt';
                open my $fh, '>>', $filename_biblio or die("Could not open file. $!");                   
                print $fh "$highestbiblionumber\n";
                close $fh;

  #print "Done processing ";

# print $art_author;  


#  print "$row\n";
}
#close $fh;

}

my $filestoprocess_biblio = "$dateyesterdayconverted".'/list_biblionumber.txt';

open(my $fh_title, '<:encoding(UTF-8)', $filestoprocess_biblio)
  or die "Could not open file '$filestoprocess_biblio' $!";

while (my $row = <$fh_title>) {
  chomp $row;
  
  #my $title = $dbh->do("SELECT `title` FROM `biblio` WHERE `biblionumber` = $row");   
  my $title = $dbh->selectrow_array("SELECT `title` FROM `biblio` WHERE `biblionumber` = $row");

  push (@titles, '<a href="http://senate-library-opacadmin.pinoysystemslibrarian.info/cgi-bin/koha/catalogue/detail.pl?biblionumber='.$row.'">'.$title.'</a>');


}

my $titles = join("\n",@titles);

my $adminbaseurl = "<a href='http://senate-library-opacadmin.pinoysystemslibrarian.info/'";
my $content_for_messagequeue = "Hello!\n\nThe following news articles from Manila Bulletin has already been automatically inputted into the Koha ILS:\n".
$titles;


my $sth_emailqueue;
#$dbh->quote($content_for_messagequeue);
#$sth_emailqueue = $dbh->prepare("INSERT INTO `message_queue` (`subject`,`content`,`letter_code`,`message_transport_type`,`status`,
#  `to_address`,`from_address`,`content_type`) VALUES   ('Automated indexing of Manila Bulletin articles',?,'AUTOMATED_INDEXING','email',
#  'pending','eugenegf\@yahoo.com',?,'text/html; charset=\"UTF-8\"')");
$sth_emailqueue = $dbh->prepare(qq{INSERT INTO `message_queue` (`subject`,`content`,`letter_code`,`message_transport_type`,`status`,
  `to_address`,`from_address`,`content_type`) VALUES ('Automated indexing of Manila Bulletin articles',?,'AUTOMATED_INDEXING','email',
  'pending','eugenegf\@yahoo.com',?,'text/html; charset=\"UTF-8\"') });

  $sth_emailqueue->execute($content_for_messagequeue,$email_from_address);
