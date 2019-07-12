<#--
    Copyright (C) 2018  niaoge<78493244@qq.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->
<@genCopyright bean/>
<@genImports bean.imports,'../'/>
import '../../stgutil/stg_util.dart';

class ${bean}<@genBeanType bean ''/><#if bean.extend> extends ${bean.parentBean}</#if> {
<#list bean.fields as f>
    <#if f.isId>
  /// ${f}
  static const String ${bean}_ID = '${f}';

        <#break>
    </#if>
</#list>
  <#list bean.fields as f>
  <#if (f.description?length>0)>
  /// ${f.description}
  </#if>
  <#assign type><@getSimpleType f/></#assign>
  <#if f.isArray>List<</#if>${type}<#if f.isArray>></#if> ${f};

  </#list>
<#if isNotEmptyList(bean.allFields)>
  ${bean}({
<#list bean.allFields as f>
    <#if !f.isSuper>this.</#if>${f},
</#list>
  })<#if bean.extend> : super(<#list bean.superFields as f>${f}: ${f}<#if f_has_next>, </#if></#list>)</#if>;
</#if>

    <#assign genericFn=''>
    <#assign genericFnName=''>
    <#list bean.allFields as f>
        <#if (f.generic?? && f.generic.isObjectClass)>
            <#if !f.isArray>
                <#assign genericFn='FromJsonFn'>
                <#assign genericFnName='genericFromJsonFn'>
            <#else>
                <#assign genericFn='FromJsonListFn'>
                <#assign genericFnName='genericFromJsonListFn'>
            </#if>
          <#break>
        </#if>
    </#list>
  static ${bean} fromJson(Map<String, dynamic> json<#if isNotEmpty(genericFn)>, ${genericFn} ${genericFnName}</#if>) {
    return ${bean}(
    <#list bean.allFields as f>
        <#assign type><@getSimpleType f/></#assign>
        <#assign j>json['${f}']</#assign>
        <#assign psJson>
            <#if f.isArray>
                <#if f.isSimple>
                    <#if (f.generic?? && !f.generic.isObjectClass)  || (!f.isGeneric) >
                        JsonUtil.parseList<${type}>(${j},JsonUtil.parse${type?cap_first})
                    <#elseif (f.generic?? && f.generic.isObjectClass)>
                        ${genericFnName}(${j})
                    <#else>
                        ${j}
                    </#if>
                <#else>${type}.fromJsonList(${j})
                </#if>
            <#else>
                <#if f.isSimple>
                  <#if (f.isGeneric && f.generic??) || (!f.isGeneric)>
                    JsonUtil.parse${type?cap_first}(${j})
                  <#else>
                    ${j}
                  </#if>
                <#else>${type}.fromJson(${j})
                </#if>
            </#if>
        </#assign>
      ${f}: <#compress>${psJson}</#compress>,
    </#list>
    );
  }

  static List<${bean}> fromJsonList(List<Map<String, dynamic>> jsonList<#if isNotEmpty(genericFn)>, ${genericFn} ${genericFnName}</#if>) {
    <#if isNotEmpty(genericFn)>
    List<${bean}> result;
    if (jsonList != null){
      result = List(jsonList.length);
      for (var json in jsonList) {
        result.add(${bean}.fromJson(json, ${genericFnName}));
      }
    }
    return result;
    <#else>
    return JsonUtil.genFromJsonList(jsonList, ${bean}.fromJson);
    </#if>
  }
}

