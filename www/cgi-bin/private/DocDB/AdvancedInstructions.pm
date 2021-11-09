# Description: The generic instructions for DocDB. This is mostly HTML, but making 
#              it a script allows us to eliminate parts of it that we don't want
#              and get it following everyone's style, and allows groups to add
#              to it with ProjectMessages.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License 
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub AdvancedInstructionsSidebar {
  print <<TOC;
  <h2>Contents</h2>
  <ul>
   <li><a href="#final">Linking to DocDB routines</a>
   <ul>
    <li><a href="#refer">Referring to your document and its files</a></li>
    <li><a href="#group">Referring to groups of documents</a></li>
   </ul></li>
   <li><a href="#xml">XML Interface</a>
   <ul>
    <li><a href="#xmldown">Download</a></li>
    <li><a href="#xmlup">Upload</a></li>
   </ul></li>
   <li><a href="#program">Programatic Interface</a></li>
  </ul>
TOC

}

sub AdvancedInstructionsBody {
  print <<HTML;
  <a name="final" />
  <h1>Notes for Advanced Users</h1>

  <a name="refer" />
  <h2>Referring to Your Document and Files</h2>

  <p>To refer to your document use the syntax <strong>$ShortProject-XXXX</strong> where XXXX is the document
  number (8 digits). You can also use the form <strong>$ShortProject-XXXX-vXX</strong> to refer to
  a specific version of a document. The <strong>$ShortProject-XXXX</strong> form refers to the
  latest version.</p>

  <h3>Linking to your document</h3>

  <p>You can also construct URL's that link to your document. The URL is of the form
  <tt>$ShowDocument?docid=XXXX&amp;version=XX</tt>,
  where the X's represent <i>just the numbers</i> of the document and version.
  (I.e. leave off the ``$ShortProject-'' and ``-v.'') As above, you can leave off the
  <tt>&amp;version=XX</tt> to refer to the latest version.</p>

  <p><strong>Using "as of" instead of version number:</strong> Instead of specifying a version
  number, you can specify <tt>&amp;asof=2002-12-25</tt> which will give you the
  version of this document current as of December 25, 2002. </p>

  <h3>Linking to files in a document</h3>

  <p>There is a script interface which fetches files from DocDB. The URL is 
  <tt>$RetrieveFile?docid=XXXX&amp;version=XX&amp;filename=xxxxxx</tt>.
  The version number can be left off to get files from the latest version number.
  The filename can also be left off. If there is only one file marked <q>Main</q>
  that file will be retrieved. 
  An alternate form is
  <tt>$RetrieveFile?docid=XXXX&amp;version=XX&amp;extension=xxx</tt>,
  so for instance you can specify PDF as the extension to retrieve the PDF file
  for a document. As above, <tt>version</tt> can be left off or <tt>asof</tt> can
  be specified.
  If your request matches no files or more than one file, the full document
  information will be shown and the user will have to choose the correct file.</p>

  <p>For both of these actions, if you want the result to be publicly accessible,
  use the URLs that point to the publicly viewable database. The document must
  also be publicly accessible for this to work.</p>

  <a name="group" />
  <h2>Referring to Groups of Documents</h2>

  <p>Any simple search can be embedded into a URL for reference from a web page.
  The most useful searches are by author, topic, keyword, or events.</p>

  <p>
  To link to a topic, you must first find out the topic ID number. 
  The easiest way to do this is to simply click on that topic from the 
  <a href="$ListTopics">list by topic</a> page.
  The URL for a single topic will be 
  <tt>$ListBy?topicid=xxx</tt>. 
  Similarly, links to documents by authors are most easily found by the 
  <a href="$ListAuthors">list by author</a> page.
  </p>
  <p>
  Use the search form to link to a keyword: 
  <tt>$Search?keywordsearchmode=anysub&amp;keywordsearch=xxxxxxx</tt>.
  </p>
  <p>
  Conferences and meetings are topics, but have special display capabilities:
  <tt>$ListByTopic?topicid=xxx&amp;mode=conference</tt> or
  <tt>$DisplayMeeting?conferenceid=xxx</tt>.
  </p>
  <p>
  If your links are from a public page, be sure to use  the links for the
  publicly accessible DocDB.  Only publicly accessible documents will be
  listed.
  </p>

  <h3>More complicated searches</h3>

  <p>By using the search capabilities, more complicated combinations of documents can be
  shown. To do this, link to the <tt>Search</tt> script with correct parameters as
  described below. Producing these kinds of searches requires an understanding of two
  additional parameters, <tt>innerlogic</tt> and <tt>outerlogic</tt>, both of which can
  have values of <tt>AND</tt> and <tt>OR</tt>. For instance, if you specify two authors,
  <tt>innerlogic=OR</tt> will return documents by <i>either</i> author while <tt>AND</tt>
  will require the document to be authored by <i>both</i> people. To understand
  <tt>outerlogic</tt>, take the example of searching for an author and a topic. 
  <tt>outerlogic=OR</tt> will require a document to either have the correct author or the
  correct topic, while <tt>AND</tt> will require both. Both options can be specified at the
  same time. <tt>outerlogic</tt> defaults to <tt>AND</tt> and <tt>innerlogic</tt> defaults
  to <tt>OR</tt>. But, this could change in the future, so specify these values if you want
  to be absolutely sure.</p>

  <p>Here is a (nearly) complete list of search parameters that can be specified:</p>
  <ul>
   <li>Title: <tt>titlesearch</tt> (text) and <tt>titlesearchmode</tt> (see search string modes)</li>
   <li>Abstract: <tt>abstractsearch</tt> (text) and <tt>abstractsearchmode</tt> (see search string modes)</li>
   <li>Keywords: <tt>keywordsearch</tt> (text) and <tt>keywordsearchmode</tt> (see search string modes)</li>
   <li>Notes and changes: <tt>revisionnotesearch</tt> (text) and <tt>revisionnotesearchmode</tt> (see search string modes)</li>
   <li>Publication info: <tt>pubinfosearch</tt> (text) and <tt>pubinfosearchmode</tt> (see search string modes)</li>
   <li>File names: <tt>filesearch</tt> (text) and <tt>filesearchmode</tt> (see search string modes). (Can be used to search
   for file names or extensions.)</li>
   <li>File descriptions: <tt>filedescsearch</tt> (text) and <tt>filedescsearchmode</tt> (see search string modes). </li>
   <li>File contents: <tt>filecontsearch</tt> (text) and <tt>filecontsearchmode</tt> (see search string modes). <em>Your admin must have enabled file content searches to use this.</em></li>
   <li>Topics: <tt>topics</tt> (numbers found with List Topics)</li>
   <li>Events: <tt>events</tt> (numbers found with List Events)</li>
   <li>Event Groups: <tt>eventgroups</tt> (numbers found with List Events)</li>
   <li>Submitter and authors: <tt>requestersearch</tt> and <tt>authors</tt> (numbers found with List Authors)</li>
   <li>Authors by name: <tt>authormanual</tt> (text)</li>
   <li>Document type: <tt>doctypemulti</tt> (numbers, look at the HTML source for <a href="$SearchForm">SearchForm</a> to find) </li>
   <li>Modification date ranges: Look at the HTML source for <a href="$SearchForm">SearchForm</a> to find the parameters and values</li>
  </ul>


  <p>For titles, abstracts, keywords, publication info, file names and file descriptions, you should specify the
  <q>searchmode</q> also. Currently there are four modes:</p>
  <ul>
   <li><tt>searchmode=anysub</tt> case-insensitive, word must be found as a substring (as opposed to a full word), and if
   more than one are specified, <i>only one</i> word must be found</li>
   <li><tt>searchmode=allsub</tt> as above, but <i>all</i> words must be found</li>
   <li><tt>searchmode=anyword</tt> or <tt>allword</tt> like above, but the word must be found surrounded by spaces</li>
  </ul> 
  <p>
  More modes can be added if required. To search for more than one word, place the code for a space (%20) between
  them.  </p>

  <p>To search for more than one author, topic, etc. (fields with numbers) you can specify more than one in the URL (see the
  examples).</p>

  <p>Examples:</p>
  <ul>
   <li>Search for documents by a keyword and an author:
    <tt>$Search?keywordsearchmode=anysub&amp;outerlogic=AND&amp;keywordsearch=test&amp;authors=1</tt></li>
   <li>Search for documents by two authors:
    <tt>$Search?authors=1&amp;authors=2&amp;innerlogic=AND</tt></li>
   <li>Search for documents by an author on a topic:
    <tt>$Search?authors=1&amp;topics=2&amp;outerlogic=AND</tt></li>
  </ul>

  <a name="xml" />
  <h1>XML Interface</h1>

  <p>An XML interface for retrieving information from and submiting information to DocDB is 
     partially complete. It is not fully complete, but it may satisfy the most common needs.</p>
     
  <a name="xmldown" />
  <h2>XML Downloads</h2>

  <p>Any link to <tt>Search</tt> or <tt>ShowDocument</tt> described above will generate XML 
     output if <tt>&amp;outformat=xml</tt> is added to the parameter list. <tt>Search</tt> returns
     a summary of the found documents while <tt>ShowDocument</tt> returns all the meta-info for
     the document.</p>

  <p>This output is easy to incorporate into your own programs and should be more
     stable than the HTML counterparts (although internal changes in DocDB's formats may change
     the XML output). Future improvements  to the XML facilities of DocDB may include XML output
     from <tt>ListBy</tt>, XML output of events, and  XML output of topic, author and other lists.
     If any of these enhancements would be useful to you, please contact your  administrator or
     the developers.</p>  

  <a name="xmlup" />
  <h2>XML Uploads</h2>

  <p>Since version 8.4 DocDB has supported uploads of XML data describing documents. This is
     done with the <a href="$XMLUpload">XMLUpload</a> script. The XML output of ShowDocument
     described above can be used almost directly to create a new document. One new XML element
     must be added to such an XMLFile and a second element is optional. Both elements must be 
     added as children of &lt;docdb&gt; (at the same level as &lt;document&gt;).</p>
     
  <p>The first XML element is <tt>control</tt> which has two parameters: <tt>mode</tt> and
     <tt>usedate</tt>. <tt>mode</tt> must be one of three values, <q>new</q>, <q>bump</q>, or <q>updatedb</q>. New
     ignores the  document ID in the uploaded XML and creates a new document with the included
     information. Bump uses  that document ID and creates a new version of that document with the
     XML information. Updatedb uses the document ID and the version and updates the metadata for that version.
     <tt>usedate</tt>, if present  (the value is unimportant) will take the
     modification dates for the document from the XML. The default is to use the current date and
     time. So the <tt>control</tt> element might look like this:</p>

     <pre>
     &lt;control&gt;
       &lt;mode&gt;new&lt;/mode&gt;
       &lt;usedate&gt;yes&lt;/usedate&gt;
     &lt;/control&gt;
     </pre> 

  <p>The second element XML element (which is optional) is <tt>authentication</tt> which contains
     the  username and password needed to download the file(s) in the document from the remote
     source. It will look like this:</p>
     
     <pre>
     &lt;authentication&gt;
       &lt;username&gt;http-basic-username&lt;/username&gt;
       &lt;password&gt;http-basic-password&lt;/password&gt;
     &lt;/authentication&gt;
     </pre> 
     
  <p>Generally speaking, when DocDB is processing an XML file, the <tt>id</tt> numbers describing 
     things  like topics, events, etc. are used and the names of those things shown in the XML
     file are ignored. Also, not all information  about a document van be uploaded via XML. This
     can be changed if there is a need for it. </p>

  <p>If the <tt>id</tt> numbers are missing, DocDB attempts a text match for the following 
     information:</p>
  <ul>
   <li>Document submitter (based on <tt>firstname</tt> and <tt>lastname</tt>)</li>
   <li>Document authors (same as submitter)</li>
  </ul>

  <p>The following information cannot be uploaded via XML:</p>
  <ul>
   <li>Cross-references either to local or remote documents</li>
   <li>Signoff lists</li>
   <li>Files are uploaded by URL only while in principle they could be uploaded by <tt>CDATA</tt>
       as well</li>
  </ul>

  <p>Finally, you will notice that there is no provision for adding files via XML. 
     This could be added but was not needed at the moment.</p>
     
  <a name="program" />
  <h1>Programatic Interface</h1>

  <p>It is also possible (and not too difficult) to write Perl programs to insert documents into
     DocDB. Examples of how to do this may be in <tt>scripts/examples</tt> in the DocDB
     source package. Help with this may also be obtained by writing the DocDB users mailing
     list linked from the <a href="$DocDBHome">DocDB homepage</a>.</p>

HTML
}

1;
