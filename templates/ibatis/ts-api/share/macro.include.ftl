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
<#macro indent text dest>
<#assign lines =StringUtil.toLines(text)>
<#list lines as line>
${dest}${line}
</#list>
</#macro>
<#macro genCopyright entity>
/**
 *  Do not remove this unless you get business authorization.
 *  <#if entity?is_string>${entity}<#else>${entity.description!}</#if>
 *  created by [stategen.progen] ,do not edit it manually otherwise your code will be override by next call progen,
 *  由 [stategen.progen]代码生成器创建，不要手动修改,否则将在下次创建时自动覆盖
 */
</#macro>
<#macro genCopyrightCanEdit entity>
/**
 *  Do not remove this unless you get business authorization.
 *  <#if entity?is_string>${entity}<#else>${entity.description!}</#if>
 *  init by [stategen.progen] ,can be edit manually ,keep when "keep this"
 *  由 [stategen.progen]代码生成器初始化，可以手工修改,但如果遇到 keep this ,请保留导出设置以备外部自动化调用
 */
</#macro>
<#macro genTypeWithGeneric r><#if r.isArray>${r.generic}[]<#else>${r.type}<#if r.isGeneric><${r.generic}></#if></#if></#macro>
<#macro getSimpleType r><#if r.isArray>${r.generic}[]<#else>${r.type}</#if></#macro>
<#function getReduceName fun genEffect><#assign text>${fun}<#if genEffect>_success</#if></#assign><#return text></#function>
<#function isNotEmpty str>
  <#return str?? && str?length gt 0>
</#function>

<#function isEmpty str>
  <#return !str?? || str?length <= 0>
</#function>

<#function isEmptyList list>
    <#return !(list??) || (list?size <= 0) >
</#function>

<#function genResultName fun>
    <#if !fun.return.isSimple>
        <#if fun.return.generic??>
            <#assign resultName>${fun.return.generic?uncap_first}<#if fun.return.isArray>s</#if><#if fun.return.isPageList>PageList</#if></#assign>
        <#else>
            <#assign resultName>${fun.return?uncap_first}<#if fun.return.isArray>s</#if></#assign>
        </#if>
    <#else>
        <#assign resultName>${fun}</#assign>
        <#assign resultName><#if resultName?starts_with("get")>${resultName?substring(3)?uncap_first}<#else>${resultName}</#if></#assign>
        <#assign indexBy=resultName?index_of("By")/>
        <#assign resultName><#if indexBy gt 0 >${resultName?substring(0,indexBy)}<#else>${resultName}</#if></#assign>
        <#assign resultName><#if resultName?starts_with("create")>${resultName?substring(6)}<#else>${resultName}</#if></#assign>
        <#assign resultName><#if resultName?starts_with("delete")>result<#else>${resultName}</#if></#assign>
        <#assign resultName><#if resultName?length =0><@genTypeWithGeneric fun.return/><#else>result</#if></#assign>
        <#assign resultName>${resultName?uncap_first}</#assign>
    </#if>
    <#return resultName>
</#function>

<#function arrayPrefix fun>
 <#if !fun.return.isArray && !fun.return.isPageList>
   <#return '['>
 <#else>
   <#return ''>
 </#if>
</#function>

<#function arraySubfix fun>
 <#if !fun.return.isArray && !fun.return.isPageList>
   <#return ']'>
 <#else>
   <#return ''>
 </#if>
</#function>

<#function doPageList fun>
    <#if fun.return.isPageList>
      <#if fun.return.type=="PageList">
          <#return '.items'>
      <#else>
          <#return '.list'>
      </#if>
    </#if>
    <#return ''>
</#function>

<#function setupName>
<#return 'setup'>
</#function>

<#function canDrawFormField f>
    <#if f="deleteFlag">
        <#return false>
    <#elseif f.isArray>
        <#return false>
    <#elseif !(f.isSimple || f.isEnum)>
        <#return false>
    <#else>
        <#return true>
    </#if>
</#function>

<#function canDrawFormParam p>
    <#if p="deleteFlag" || p="page" || p="pageSize" || p="pageNum" || p.isPagination>
        <#return false>
    <#else>
        <#return true>
    </#if>
</#function>
<#macro genImports imports,relativePath>
    <#list imports as import>
        <#if import.importPath??>
import ${import} from "${relativePath}${import.importPath}/${import}";
        <#else>
${import.wholeImportPath};
        </#if>
    </#list>
</#macro>

<#function genArea bean>
<#assign areaName>${bean?uncap_first}Area</#assign>
<#return areaName>
</#function>

<#macro genFormConfigsInteface bean f ind>
<#assign text>
  <#if (f.description?length gt 0)>
/** ${f.description}  ${f.temporalType!}*/
  </#if>
${f?cap_first}?: typeof ${bean?uncap_first}_${f} & Partial<FormItemConfig>,
</#assign>
<@indent text ind/>
</#macro>

<#macro genSelectOptionConsts f>
const ${f.type?uncap_first}SelectOptions= makeSelectOptions(${f.type?uncap_first}Options);
</#macro>

<#macro  genFieldProps bean field ind>
<#assign text>
name: '${field}',
<#if field.hidden>
hidden: true,
</#if>
<#if field.isId>
isId: true,
</#if>
<#if field.isEnum>
isEnum: true,
options: <#if field.isGeneric>${field.generic?uncap_first}<#else>${field.type?uncap_first}</#if>Options,
</#if>
<#if field.isImage>
isImage: true,
</#if>
<#if field.isArray>
isArray: true,
</#if>
<#if field.temporalType??>
temporalType : TemporalType.${field.temporalType},
format: ${field.temporalType}_FORMAT,
</#if>
label: '${field.title}',
<#if isNotEmpty(field.editorType!)>
type: '${field.editorType}',
</#if>
<#if field.optionConfig??>
optionConfig: {
  bean: '${field.optionConfig.bean}',
  <#if field.optionConfig.none??>
  none: '${field.optionConfig.none}',
  </#if>
  <#if field.optionConfig.changeBy??>
  changeBy: '${field.optionConfig.changeBy}',
  </#if>
  <#if field.optionConfig.defaultOption??>
  defaultOption: '${field.optionConfig.defaultOption}',
  </#if>
},
</#if>
UIEditor: UIUtil.Build${getEditorName(field)}Editor,
Editor: UIUtil.Build${getEditorName(field)}Editor,
config: {
  initialValue: null,
    <#if field.rules?size gt 0>
  rules: [
        <#list field.rules as rule>
    {
            <#if (rule.required?? && rule.required ) || (field.required?? && field.required)>
      required: true,
            </#if>
            <#if rule.max??>
      max: ${rule.max?c},
            </#if>
            <#if rule.min??>
      min: ${rule.min?c},
            </#if>
            <#if rule.message??>
      message: "${rule.message}",
            </#if>
            <#if rule.pattern??>
      pattern: /${rule.pattern}/,
            </#if>
            <#if rule.whitespace??>
      whitespace: true,
            </#if>
    },
        </#list>
  ],
    </#if>
}
</#assign>
<@indent text ind/>
</#macro>

<#function  genValueConfigs field bean>
  <#assign value>
      <#compress>
          <#if field.temporalType??>
              <#assign initialValue>${bean?uncap_first}.${field} ? moment(${bean?uncap_first}.${field}) : null</#assign>
              ${initialValue}
          <#else>
              ${bean?uncap_first}.${field}
          </#if>
      </#compress>
  </#assign>
  <#return value>
</#function>

<#function  getEditorName field>
    <#assign configName=field>
    <#if field.editorType?length gt 0>
        <#assign customBuild=field.editorType?cap_first>
    <#elseif field.temporalType??>
        <#assign format>${field.temporalType}_FORMAT</#assign>
        <#if field.temporalType=='TIMESTAMP'>
            <#assign customBuild='TimeStamp'>
        <#elseif field.temporalType=='TIME'>
            <#assign customBuild='TimePicker'>
        <#else>
            <#assign customBuild='DatePicker'>
        </#if>
        <#assign customBuild>${customBuild}</#assign>
    <#elseif field.isEnum>
        <#assign  customBuild>Enum</#assign>
    <#elseif field.isImage>
        <#assign customBuild>Image</#assign>
    <#elseif field.optionConfig??>
        <#assign customBuild>Select</#assign>
    <#else>
        <#assign customBuild='Input'>
    </#if>
    <#return customBuild>
</#function>
<#macro genFormFunctions fun field ind>
  <#assign customBuild=getEditorName(field)>
  <#assign text>
((props?: UIUtil.${customBuild}EditorProps) => {
  return UIUtil.rebuildEditor(props, ${fun?uncap_first}_${field});
}) as any;
</#assign>
<@indent text ind/>
</#macro>

<#macro formImports>
import UIUtil from "@utils/UIUtil";
import {
  FormItemConfig, FormItemConfigMap, ObjectMap, TIME_FORMAT, DATE_FORMAT, TIMESTAMP_FORMAT,
  TemporalType, PagesProps, rebuildFormItemConfigs
} from "@utils/DvaUtil";
import moment from 'moment';
</#macro>
<#macro genBeanType bean genName><#if bean.genericFields?? ><<#list bean.genericFields as g><#if genName?length gt 0>${genName}<#else>${g.genericName}</#if><#if g_has_next>, </#if></#list>></#if></#macro>
<#function genType p>
    <#if p.isArray>
      <#assign result>${p.generic}[]</#assign>
    <#else>
        <#assign result>${p.type}<#if p.isGeneric><${p.generic}></#if></#assign>
    </#if>
    <#return result>
</#function>

<#function appendParam paramsStr pStr>
   <#assign result=paramsStr>
   <#if pStr?length gt 0>
   <#assign result>${paramsStr}<#if paramsStr?length gt 0>, </#if>${pStr}</#assign>
   </#if>
   <#return result>
</#function>

<#function genTypeAndNames params doRequired>
   <#assign hasPage=false>
   <#assign hasPageSize=false>
   <#list params as p>
   <#if p=='page'>
       <#assign hasPage=true>
   </#if>
   <#if p=='pageSize'>
       <#assign hasPageSize=true>
   </#if>
  </#list>
  <#assign paramsStr=''>
  <#list params as p>
    <#if p.type=='PaginationProps' || p.type=='Pagination'>
        <#assign paginationStr=''>
        <#if !hasPage>
           <#assign paginationStr>${appendParam(paginationStr,'page?: number')}</#assign>
        </#if>
        <#if !hasPageSize>
           <#assign paginationStr>${appendParam(paginationStr,'pageSize?: number')}</#assign>
        </#if>
        <#assign paramsStr>${appendParam(paramsStr,paginationStr)}</#assign>
    <#else>
        <#assign pStr>${p}<#if !p.required || !doRequired>?</#if>: ${genType(p)}</#assign>
        <#assign paramsStr>${appendParam(paramsStr,pStr)}</#assign>
    </#if>
  </#list>
  <#return  paramsStr>
</#function>



<#function nextEffectName fun>
    <#return fun+'_next'>
</#function>

<#function refreshEffectName fun>
    <#return fun+'_refresh'>
</#function>



<#macro genFieldDescription f ind>
<#assign text>
<#if (f.description?length gt 0)>
/** ${f.description} ${f.temporalType!}*/
</#if>
</#assign>
<#if text?? && text?length gt 0>
<@indent text ind/>
</#if>
</#macro>

<#macro assginField bean f dataName ind>
<#assign text>
<#assign value=genValueConfigs(f, dataName)>
const ${bean?uncap_first}_${f}Value = ${value};
</#assign>
<#if text?? && text?length gt 0>
<@indent text ind/>
</#if>
</#macro>