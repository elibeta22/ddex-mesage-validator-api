<h1>DDEX XML Validator</h1>
<p>DDEX XML Validator is an API that can be used to validate
XML documents against schema (XSD) and advanced XML validation (Schematron). XML validator checks to see if an XML document is valid and well formed. A well formed document must meet the standards of XML syntax rules, whereas a valid document must meet the standards of a XML Schema.
</p>
<h2>Requirements</h2>
<ul>
  <li>Windows</li>
  <li>Unix</li>
  <li>Maven</li>
</ul>

<h2>Building</h2>
<p>To build the source you can run the command in the project directory.</p>
<pre>mvn clean install</pre>
<p>After, a file with the name ddex-message-validator-api-1.0-SNAPSHOT-bin.zip will appear in 'target/' directory. Unzip the file and and you will see three folders bin, etc, repo. Within the bin folder you will also see start-api.sh and start-api.bat. In your command line you can start the API by typing the following below.</p>
<pre>start-api</pre>
<p>If you are using IntelliJ or Eclipse you can also run it from within your IDE locally. </p>
