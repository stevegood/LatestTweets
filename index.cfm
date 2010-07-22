<!---
	Copyright 2009 Steve Good / Slantsoft

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	   http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
--->

<cfinclude template="plugin/config.cfm" />

<cfsavecontent variable="body">
<cfoutput>
	<h2>#request.pluginConfig.getName()#</h2>
	
	<p>The Latest Tweets plugin allows you to easily display your last few tweets from your public twitter timeline in your Mura content using a simple tag syntax.</p>
	<p>The format for the LatestTweets tag is as follows:
	<p>[LatestTweets twitterName:{your_twitter_name} <em>maxTweets:{number_of_tweets}</em> <em>wrapperClass:{class_name}</em>]</p>
	<table border="1">
	  <tr>
	    <th scope="col">Attribute</th>
	    <th scope="col">Required?</th>
	    <th scope="col">Default</th>
	    <th scope="col">Explanation</th>
	  </tr>
	  <tr>
	    <td>twitterName</td>
	    <td>yes</td>
	    <td>&nbsp;</td>
	    <td>Your twitter username.</td>
	  </tr>
	  <tr>
	    <td>maxTweets</td>
	    <td>no</td>
	    <td>5</td>
	    <td>The maximum tweets to display</td>
	  </tr>
	  <tr>
	    <td>wrapperClass</td>
	    <td>no</td>
	    <td>myTwitterTimeline</td>
	    <td>The default CSS class assigned to the wrapper around your tweets</td>
	  </tr>
	</table>
	<h3>Examples</h3>
	<h4>Inline with your content</h4>
	<p>For the twitter user 'stevegood' you would use:</p>
	<pre>[LatestTweets twitterName:stevegood]</pre><br />
	<p>To display the last 3 tweets from 'stevegood' use:</p>
	<pre>[LatestTweets twitterName:stevegood maxTweets:3]</pre><br />
	<p>To display the last 3 tweets from 'stevegood' and override the default CSS use (see the default CSS below):</p>
	<pre>[LatestTweets twitterName:stevegood maxTweets:3 wrapperClass:myTweets]</pre><br />
	
	<h4>In a Mura component</h4>
	<p>For the twitter user 'stevegood' you would use:</p>
	<pre>[mura]event.getValue('LatestTweets').showTweets(twitterName='stevegood')[/mura]</pre><br />
	<p>To display the last 3 tweets from 'stevegood' use:</p>
	<pre>[mura]event.getValue('LatestTweets').showTweets(twittername='stevegood',maxTweets='3')[/mura]</pre><br />
	<p>To display the last 3 tweets from 'stevegood' and override the default CSS use (see the default CSS below):</p>
	<pre>[mura]event.getValue('LatestTweets').showTweets(twittername='stevegood',maxTweets='3',wrapperClass='myTweets')[/mura]</pre><br />
	
	<p>Default CSS</p>
	<pre>
&lt;style type="text/css"&gt;
.myTwitterTimeline {
	word-wrap:normal;
}
.myTwitterTimeline a {
	text-decoration:none;
}
.myTwitterTimeline a:hover {
	text-decoration:underline;
}
.myTwitterTimeline .ttTweet {
	font-size:100%;
	border-top:1px ##CCC dotted;
	padding: 5px 5px 5px 5px;
	margin-bottom:0;
}
.myTwitterTimeline .ttDate {
	font-size:10px;
	margin: 0 0 0 5px;
	color:##CCC;
}
&lt;/style&gt;
	</pre>
	<h3>Important</h3>
	<p>Please follow the syntax of the examples above exactly. Do not leave spaces between the colons an the attribute names/values in the tag. Also don't surround attribute values with quotes and leave no spaces between the enclosing square brackets and the tag content.</p>

</cfoutput>
</cfsavecontent>
<cfoutput>#application.pluginManager.renderAdminTemplate(body=body,pageTitle=request.pluginConfig.getName())#</cfoutput>