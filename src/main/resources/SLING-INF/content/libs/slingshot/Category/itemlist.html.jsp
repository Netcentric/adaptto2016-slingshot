<%--
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at
    
    http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
--%><%@page session="false" %><%
%><%@page import="java.util.Iterator,
                  java.util.List,
                  org.apache.sling.api.resource.Resource,
                  org.apache.sling.sample.slingshot.SlingshotConstants" %><%
%><%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><sling:defineObjects/><%
%><div class="metro ui-slingshot-content">
 <%
     int i = 0;
     final Iterator<Resource> fi = resource.listChildren();
     while ( fi.hasNext()) {
         final Resource current = fi.next();
         if ( current.isResourceType(SlingshotConstants.RESOURCETYPE_ITEM)) {
             %>
             <sling:include resource="<%= current %>" replaceSelectors="main"/>
             <%
         }
     } 
  %>
</div>
