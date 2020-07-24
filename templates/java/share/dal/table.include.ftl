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
<#assign className = table.className>
<#assign classNameLower = className?uncap_first>
 <#assign crt_dt_clmn="">
 <#assign upt_dt_clmn="">
 <#assign sft_dlt_clmn="">
 <#assign updated_date_fields=Setting.getUpdated_date_fields()>
 <#assign created_date_fields=Setting.getCreated_date_fields()>
 <#assign soft_delete_fields=Setting.getSoft_delete_fields()>
 <#assign is_create_time_long=false>
 <#assign is_update_time_long=false>
  <#list table.columns as column>
        <#assign clumn_u=column.sqlName?upper_case >
        <#if CollectionUtil.mapContainsKey(updated_date_fields,clumn_u)>
            <#assign upt_dt_clmn=column.sqlName>
            <#assign is_update_time_long=column.javaType?lower_case?contains('long')>
        <#elseif CollectionUtil.mapContainsKey(created_date_fields,clumn_u)>
           <#assign crt_dt_clmn=column.sqlName>
           <#assign is_create_time_long=column.javaType?lower_case?contains('long')>
        <#elseif CollectionUtil.mapContainsKey(soft_delete_fields,clumn_u)>
           <#assign sft_dlt_clmn=column.sqlName>
        </#if>
  </#list>
<#assign unSelectColumns =[crt_dt_clmn,upt_dt_clmn,sft_dlt_clmn]>
<#assign hasSftDel=false>
<#if sft_dlt_clmn!=""><#assign hasSftDel=true></#if>
<#assign pkColumn=table.pkColumn>
<#assign levelName=StringUtil.findByRex(table.remarks!,'(?<=(-level)\\()[^\\)]+')>
<#assign ownerName=StringUtil.findByRex(table.remarks!,'(?<=(-owner)\\()[^\\)]+')>
<#if StringUtil.isNotEmpty(levelName)>
   <#-- table命令中的tableConfigSet延时被动解析,调用时生效 -->
    <#assign levelTable=tableConfigSet.getBySqlName(levelName)>
    <#assign lpkColumn=levelTable.pkColumn>
</#if>
<#if StringUtil.isNotEmpty(ownerName)>
    <#-- table命令中的tableConfigSet延时被动解析,调用时生效 -->
    <#assign ownerTable=tableConfigSet.getBySqlName(ownerName)>
    <#assign opkColumn=ownerTable.pkColumn>
</#if>
<#function andDelFlg prefix>
<#if sft_dlt_clmn!="">
    <#return "and ${prefix}${sft_dlt_clmn} = 0">
</#if>
</#function>
<#function getCurName column>
<#return "current${column.columnName?cap_first}">
</#function>
<#assign levelFix="_level_h">
<#assign flatFix="_flat_h">
<#assign ownerFix="_owner_h">
<#macro levelLeftJoin>
    <#if lpkColumn??>
           <isNotNull property="${getCurName(lpkColumn)}">
           left join ${table.sqlName}${levelFix} h on (a.${pkColumn.sqlName} = h.${pkColumn.sqlName})
           </isNotNull>
    </#if>
    <#if opkColumn??>
           <isNotNull property="${getCurName(opkColumn)}">
           left join ${table.sqlName}${ownerFix} o on (a.${pkColumn.sqlName} = o.${pkColumn.sqlName})
           left join ${ownerTable.sqlName} u on (u.${opkColumn.sqlName} = o.${opkColumn.sqlName})
           </isNotNull>
    </#if>
</#macro>
<#macro levelSelectIn>
    <#if lpkColumn?? && opkColumn??>
             <isNotNull property="${getCurName(lpkColumn)}">
               <isNull property="${getCurName(opkColumn)}">
                 and h.${lpkColumn.sqlName} in (select ${lpkColumn.sqlName} from ${levelTable.sqlName}${flatFix} where parent_id = #${getCurName(lpkColumn)}# ${andDelFlg("")})
               </isNull>
             </isNotNull>
             <isNotNull property="${getCurName(opkColumn)}">
               <isNull property="${getCurName(lpkColumn)}">
                 and (o.${opkColumn.sqlName} = #${getCurName(opkColumn)}# ${andDelFlg("u.")})
               </isNull>
             </isNotNull>
             <isNotNull property="${getCurName(lpkColumn)}">
               <isNotNull property="${getCurName(opkColumn)}">
                 and (h.${lpkColumn.sqlName} in (select ${lpkColumn.sqlName} from ${levelTable.sqlName}${flatFix} where parent_id = #${getCurName(lpkColumn)}# ${andDelFlg("")}) or (o.${opkColumn.sqlName} = #${getCurName(opkColumn)}# ${andDelFlg("u.")}) )
               </isNotNull>
             </isNotNull>
    </#if>
    <#if opkColumn?? && !(opkColumn??)>
             <isNotNull property="${getCurName(opkColumn)}">
               and o.${opkColumn.sqlName} in (select ${opkColumn.sqlName} from ${ownerTable.sqlName}${flatFix} where parent_id = #${getCurName(opkColumn)}# ${andDelFlg("")})
             </isNotNull>
    </#if>
    <#if !(opkColumn??) && opkColumn>
             <isNotNull property="${getCurName(opkColumn)}">
               and (o.${opkColumn.sqlName} = #${getCurName(opkColumn)}# ${andDelFlg("u.")})
             </isNotNull>
    </#if>
</#macro>
<#macro levelSelectExists>
    <#if lpkColumn?? && opkColumn??>
             <isNotNull property="${getCurName(lpkColumn)}">
               <isNull property="${getCurName(opkColumn)}">
                 and exists (select null from ${levelTable.sqlName}${flatFix} where ${lpkColumn.sqlName} = h.${lpkColumn.sqlName} and parent_id = #${getCurName(lpkColumn)}# ${andDelFlg("")})
               </isNull>
             </isNotNull>
             <isNotNull property="${getCurName(opkColumn)}">
               <isNull property="${getCurName(lpkColumn)}">
                 and (o.${opkColumn.sqlName} = #${getCurName(opkColumn)}# and ${andDelFlg("u.")})
               </isNull>
             </isNotNull>
             <isNotNull property="${getCurName(lpkColumn)}">
               <isNotNull property="${getCurName(opkColumn)}">
                 and (exists (select null from ${levelTable.sqlName}${flatFix} where ${lpkColumn.sqlName} = h.${lpkColumn.sqlName} and parent_id = #${getCurName(lpkColumn)}# ${andDelFlg("")}) or (o.${opkColumn.sqlName} = #${getCurName(opkColumn)}# ${andDelFlg("u.")}) )
               </isNotNull>
             </isNotNull>
    </#if>
    <#if opkColumn?? && !(opkColumn??)>
             <isNotNull property="${getCurName(opkColumn)}">
               and exists (select null from ${levelTable.sqlName}${flatFix} where ${lpkColumn.sqlName} = h.${lpkColumn.sqlName} and parent_id = #${getCurName(lpkColumn)}# ${andDelFlg("")})
             </isNotNull>
    </#if>
    <#if !(opkColumn??) && opkColumn>
             <isNotNull property="${getCurName(opkColumn)}">
               and (o.${opkColumn.sqlName} = #${getCurName(opkColumn)}# ${andDelFlg("u.")})
             </isNotNull>
    </#if>
</#macro>
<#macro levelParams>
    <#if lpkColumn?? || opkColumn??>
        <extraparams>
        <#if lpkColumn??>
           <param name="${getCurName(lpkColumn)}" javaType="${lpkColumn.simpleJavaType}"/>
        </#if>
        <#if opkColumn??>
           <param name="${getCurName(opkColumn)}" javaType="${opkColumn.simpleJavaType}"/>
        </#if>
        </extraparams>
    </#if>
</#macro>
<#macro nullLevelIdsubfix hasLevelColumn>
<#if hasLevelColumn>
NoLevelAuthority
</#if>
</#macro>

