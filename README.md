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

<h2>Working with the code</h2>
<p>If you don't have a personal IDE preference we recommend you use IntelliJ when working with the code. We use the maven <a href="http://maven.apache.org/plugins/maven-assembly-plugin/">assembly</a> and
<a href="http://www.mojohaus.org/appassembler/appassembler-maven-plugin/">appassembly</a> plugin for wrapper script packaging support.</p>
<h3>Technologies</h3>
<ul>
  <li>Java</li>
  <li>Spring</li>
  <li>Embedded Jetty</li>
  <li>SAX</li>
  <li>Logback</li>
</ul>
<p>The API uses <a href="https://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html">Spring-WebMVC</a> framework which provides a Model-View-Controller architecture. Having a MVC structure in our application allows for the input logic, business logic, and UI logic to be seperated but still have the flexible ability to loosely couple these elements together.</p>
<pre>curl -X POST -F 'schemaVersion=3.4.1' -F 'ernFile=@C:\ddex-mesage-validator-api-master\xml\sme-album.xml' localhost:6060/api/json/validateSchema</pre>


