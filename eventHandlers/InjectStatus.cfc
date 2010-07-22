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
<cfcomponent extends="mura.plugin.pluginGenericEventHandler">
	
	<cffunction name="onApplicationLoad" output="false" returntype="void">
		<cfargument name="event" />
	</cffunction>
	
	<cffunction name="onSiteRequestStart" output="false" returntype="void">
		<cfargument name="event" />
		
		<cfset event.setValue('LatestTweets',this) />
	</cffunction>
	
	<cffunction name="onRenderStart" output="false" returntype="void">
		<cfargument name="event">
		<cfset var body = "" />
		<cfif pluginConfig.getSetting("isEnabled") eq "yes">
			<cfset body = event.getContentBean().getBody()>
			<cfset body = parseTags(body) />
			<cfset event.getContentBean().setBody(body) />
		</cfif>
	</cffunction>
	
	<cffunction name="showTweets" access="public" returntype="String" output="false">
		<cfargument name="twittername" type="String" required="true" />
		<cfargument name="maxtweets" type="Numeric" required="false" default="5" />
		<cfargument name="wrapperClass" type="String" required="false" default="myTwitterTimeline" />
				
		<cfreturn getTwitterJS(ArgumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="parseTags" access="private" returntype="any" output="false">
		<cfargument name="contentBody" required="true" />
		
		<cfset var local = StructNew() />
		<cfset local.tagRE = '\[LatestTweets.+?\]' />
		<cfset local.tagBody = "" />
		<cfset local.parsedContent = arguments.contentBody />
		<cfset local.noMoreMatches = false />
		<cfset local.startPosition = 1 />
		<cfset local.tagParams = StructNew() />
		
		<cfloop condition="local.noMoreMatches is false">
			<cfset local.tagMatch = reFindNoCase(local.tagRE,arguments.contentBody,local.startPosition,true) />
			<cfif local.tagMatch.len[1] eq 0>
				<cfset local.noMoreMatches = true />
			<cfelse>
				<cftry>
					<!--- get the tag code --->
					<cfset local.tagBody = mid(arguments.contentBody,local.tagMatch.pos[1],local.tagMatch.len[1]) />
					<!--- get the tag params --->
					<cfloop list="twittername,maxtweets,wrapperClass" index="local.thisParam">
						<cfset local.tagParams[local.thisParam] = reFindNoCase("#thisParam#:.+?[\] ]",local.tagBody,1,true) />
						<cfif local.tagParams[local.thisParam]["pos"][1] neq 0>
							<cfset local.tagParams[local.thisParam] = right(mid(local.tagBody,local.tagParams[local.thisParam]["pos"][1],local.tagParams[local.thisParam]["len"][1]-1),local.tagParams[local.thisParam]["len"][1]-(len(local.thisParam)+2)) />
						<cfelse>
							<cfset structDelete(local.tagParams,local.thisParam) />	
						</cfif>
					</cfloop>
					<!--- replace tag with code --->
					<cfset local.parsedContent = replaceNoCase( local.parsedContent,local.tagBody,getTwitterJS(argumentCollection=local.tagParams),"all" ) />
					<cfcatch type="any">
						<cfset local.parsedContent = replaceNoCase( local.parsedContent,local.tagBody,"An error occurred while loading your tweets. Please check your LatestTweets tag syntax.","all" ) />
					</cfcatch>
				</cftry>
				<!--- set counter for the next tag --->
				<cfset local.startPosition = local.tagMatch.pos[1] + len(local.tagBody) />
			</cfif>
		</cfloop>
		<cfreturn local.parsedContent />
	</cffunction>
	
	<cffunction name="getTwitterJS" access="private" returntype="any" output="false">
		<cfargument name="twittername" type="String" required="true" />
		<cfargument name="maxtweets" type="Numeric" required="false" default="5" />
		<cfargument name="wrapperClass" type="String" required="false" default="myTwitterTimeline" />
		
		<cfset var local = StructNew() />
		<cfset local.uniqueElementID = CreateUUID() />
		
		<cfsavecontent variable="local.code">
		<cfoutput>
		
		<cfif arguments.wrapperClass EQ 'myTwitterTimeline'>
			<style type="text/css">
			.#arguments.wrapperClass# {
				word-wrap:normal;
			}
			.#arguments.wrapperClass# a {
				text-decoration:none;
			}
			.#arguments.wrapperClass# a:hover {
				text-decoration:underline;
			}
			.#arguments.wrapperClass# .ttTweet {
				font-size:100%;
				border-bottom:1px ##CCC dotted;
				padding:	5px 5px 5px 5px;
				margin-bottom:0;
			}
			.#arguments.wrapperClass# .ttDate {
				font-size:10px;
				margin: 0 0 0 5px;
				color:##CCC;
			}
			</style>
		</cfif>
		
		<div id="#local.uniqueElementID#" class="#arguments.wrapperClass# svFeed svIndex clearfix">
			<dl class="first last">
				<dd class="ttTweets">Loading tweets...</dd>
			</dl>
		</div>
		
		<script type="text/javascript">
		if (typeof jQuery === 'undefined'){
			var secProtocol = (("https:" == document.location.protocol) ? "https://" : "http://");
			document.write(unescape("%3Cscript src='" + secProtocol + "ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js' type='text/javascript'%3E%3C/script%3E"));
		}
		</script>
		
		<script type="text/javascript" language="JavaScript">
		$(document).ready(function(){
			var displayMax = #arguments.maxtweets#;
			var ttAccount = '#arguments.twittername#';
			var jsonpURL = 'http://twitter.com/status/user_timeline/' + ttAccount + '.json?callback=?';
			
			$(document).bind("getTweets-#local.uniqueElementID#",function(){
				// this is where we should make our json call to the Twitter API
				// Having javascript making the request should prevent rate limit caps
				$.getJSON(
					jsonpURL,
					{},
					function(result){
						$('###local.uniqueElementID# .ttTweets').html('<h4>Recent Tweets<br/><a href=\"http://twitter.com/' + ttAccount + '\" target="_blank">@' + ttAccount + '</a></h4>');
						for (var i = 0; i < displayMax; i++){
							var tweet_date = new Date(result[i].created_at);
							var date_now = new Date();
							var date_diff = date_now - tweet_date;
							var span = date_diff/(1000*60*60*24);
							var label = 'day';
							
							if (span < 1){
								span = Math.round(date_diff/(1000*60*60));
								label = 'hour';
							}
										
							if (span <= 0){
								span = Math.round(date_diff/(1000*60));
								label = 'minute';
							}
							if (span <= 0){
								span = Math.round(date_diff/(1000));
								label = 'second';
							}
							
							if (label == 'day'){
								span = Math.round(span);
							}
							
							if (span > 1){
								label += 's';
							}
							
							var tweet_text = result[i].text;
								tweet_text = tweet_text.replace(/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w/_\.]*(\?\S+)?)?)?)/,'<a href=\"$1\" target=\"_blank\">$1</a>');
								tweet_text = tweet_text.replace(/(@\w+)/gi,'<a href=\"http://twitter.com/$1\" target=\"_blank\">$1</a>');
								tweet_text = tweet_text.replace('/@','/');
								tweet_text = tweet_text.replace(/(##\w+)/gi,'<a href=\"http://search.twitter.com/search?q=$1\" target=\"_blank\">$1</a>');
								tweet_text = tweet_text.replace('q=##','q=%23');
							var html = '<dd class=\"ttTweet\">';
								html += tweet_text;
								if (!isNaN(span)) {
									html += '<span class=\"ttDate\"> ' + span + ' ' + label + ' ago</span>';
								}
								html += '</dd>';
							$('###local.uniqueElementID# .ttTweets').append(html);
						}
					}
				);
			});
			$(document).trigger("getTweets-#local.uniqueElementID#");
		});
		</script>
		
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.code />
	</cffunction>
	
</cfcomponent>