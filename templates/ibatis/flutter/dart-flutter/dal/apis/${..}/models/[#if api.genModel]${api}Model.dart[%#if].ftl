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
<@genCopyright api/>

import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

<@genImports api.imports,'../'/>
import '../../stgutil/stg_util.dart';
import '../interfaces/${fixImport(api)}Faces.dart';
import '../apis/${fixImport(api)}Apis.dart';

abstract class ${api}Command {
<#--<#if api.inits?size gt 0>
  static ${setupName()}_effect async ({payload}, {call, put, select}) {
    let newPayload = {};
    <#assign checknames=''>
    <#if api.inits?size gt 1>
        <#assign paramsStr =''>
        <#list api.inits as fun>
        <#assign paramsStr>${appendParam(paramsStr,fun+'Params = null')}</#assign>
        </#list>
    const {${paramsStr}, ...lastParams} = payload || {};
    </#if>

    <#list api.inits as fun>
    /** ${fun.description} */
        <#if fun.state.genEffect>
    const ${fun}Payload = yield ${api}Command.${fun}_effect({payload<#if api.inits?size gt 1>: {...lastParams, ...${fun}Params}</#if>}, {call, put, select});
    newPayload = ${api}Command.${getReduceName(fun, fun.state.genEffect)}_reducer(<${api}State>newPayload, ${fun}Payload);
        <#else>
    newPayload = ${api}Command.${getReduceName(fun, fun.state.genEffect)}_reducer(<${api}State>newPayload, {});
        </#if>
    </#list>
    return newPayload;
  };

  <#assign reducerName>${getReduceName(setupName(), true)}</#assign>
  static ${reducerName}_type(payload) {
    return {type: "${reducerName}", payload: payload};
  }

</#if>-->
<#function genOldAreaStr fun>
  <#local oldAreaStr>var old${genArea(fun.area)?cap_first} = Provider.of<${api}State>(context).${genArea(fun.area)};</#local>
  <#return oldAreaStr>
</#function>
<#list api.functions as fun>
  <#if fun.state.genEffect>

  <#assign genEffect=true>
  /// ${fun.description}
  static dynamic ${fun} (BuildContext context, <#if isEmptyList(fun.params)><#else><#if fun.json??>${fun.json}: ${genType(fun.json)}<#else>{Map<String, dynamic> payload, ${genTypeAndNames(fun.params,true)} }</#if></#if>) async {
    <#assign state =fun.state>
    <#assign resultName>${genResultName(fun)}</#assign>
    <#assign returnTypeWithGeneric><@genTypeWithGeneric fun.return/></#assign>
    <#assign oldAreaStr=''>
    <#assign writeArea=false>
    <#assign writeResult=false>
    <#assign newMap=''>
    <#assign isOne =false>
    <#assign r=fun.return>
    <#if fun.params?size==1><#assign one=fun.params[0]><#assign isOne =true></#if>
    <#if r.isPageList && fun.area??>
      <#assign oldAreaStr=genOldAreaStr(fun)>
    ${oldAreaStr}
    payload = {<#if r.isPageList>'page': 1, 'pageSize': 10, </#if>...old${genArea(fun.area)?cap_first}.queryRule, ...payload};
    </#if>
    <#if !r.isVoid><@genTypeWithGeneric r/> ${resultName} = </#if>await ${api}Apis.${fun}(<#if isNotEmptyList(fun.params)><#if isOne>null, </#if>payload: payload, ${genParamsStr(fun.params)}</#if>);
    <#if !r.isVoid>
      <#if r.isSimpleResponse>
    if (${resultName} != null && !${resultName}.success) {
      throw ${resultName}.message;
    }
      <#assign resultName>payload</#assign>
      </#if>
      <#if fun.area?? && fun.area.idKeyName??>
        <#assign writeArea=true>
        <#if !r.isSimpleResponse>
          <#assign newMap>${fun.area?uncap_first}Map</#assign>
          <#if newMap=resultName>
              <#assign newMap>new${fun.area}Map</#assign>
          </#if>
          <#if state.dataOpt!='FULL_REPLACE' && oldAreaStr?length ==0>
    ${genOldAreaStr(fun)}
          </#if>
          <#if r.isPageList>
    var pagination = ${resultName}?.pagination;
          </#if>
    <#assign toMapParam><#if !r.isArray && !r.isPageList>[</#if>${resultName}${doPageList(fun)}<#if !r.isArray && !r.isPageList>]</#if></#assign>
    <#assign typeToMap><#if !r.isSimple>${getSimpleType(r)}.toMap(</#if>${toMapParam}<#if !r.isSimple>)</#if></#assign>
          <#if state.dataOpt='APPEND_OR_UPDATE'>
    var ${newMap} = CollectionUtil.appendOrUpdateMap(old${genArea(fun.area)?cap_first}.valueMap,  ${typeToMap});
          <#elseif state.dataOpt='DELETE_IF_EXIST'>
    var ${newMap} = CollectionUtil.deleteMap(old${genArea(fun.area)?cap_first}.valueMap, ${typeToMap});
          <#else>
            <#assign newMap>${typeToMap}</#assign>
          </#if>
        </#if>
      <#else>
        <#assign writeResult=true>
      </#if>
  </#if>

    var newAreaState = AreaState(
    <#if writeArea>
        <#if newMap?length gt 0>
      valueMap: ${newMap},
        </#if>
        <#if r.isPageList>
      pagination: pagination,
        </#if>
      <#if r.isPageList || fun.state.genRefresh>
      queryRule: payload,
      </#if>
    );
    </#if>
    return newAreaState;
  }

  <#if r.isPageList && fun.area??>

  static dynamic ${nextEffectName(fun)}(BuildContext context) async {
    ${genOldAreaStr(fun)}
    var pagination = old${genArea(fun.area)?cap_first}?.pagination;
    var page = pagination?.current;
    page = (page != null ? page : 0) + 1;
    var totalPages = (pagination.total / (pagination?.pageSize ?? 10)).ceil();
    page = Math.min(page, totalPages);
    var payload = {...old${genArea(fun.area)?cap_first}.queryRule, 'page': page};
    var newAreaState = await ${api}Command.${fun}(context,payload: payload);
    return newAreaState;
  }
    </#if>
    <#if fun.state.genRefresh>

  static dynamic ${refreshEffectName(fun)}(BuildContext context) async {
    ${genOldAreaStr(fun)}
    var payload = {...old${genArea(fun.area)?cap_first}.queryRule};
    var newAreaState = await ${api}Command.${fun}(context,payload: payload);
    return newAreaState;
  }
      </#if>
  </#if>
</#list>
}

class ${api}Model with ChangeNotifier<#-- implements ${api}AbstractModel--> {
<#--<#if api.inits?size gt 0>
  void ${setupName()} async ({dispatch, history}){
  history.listen((listener) => {
    const pathname = listener.pathname;
    const keys = [];
    const match = RouteUtil.getMatch(${api?uncap_first}Model.pathname, pathname,keys);
    if (!match) {
      return;
    }
    let payload = {...RouteUtil.getQuery(listener)} ;
        <#assign paramNames=''>
        <#list api.inits as fun>
    const ${fun}Params = ${api?uncap_first}Model.${fun}InitParamsFn ? ${api?uncap_first}Model.${fun}InitParamsFn({pathname, match, keys}) : null;
        <#assign paramNames><#if paramNames?length gt 0>${paramNames}, </#if>${fun}Params</#assign>
        </#list>
    payload = {...payload, <#if api.inits?size gt 1>${paramNames}<#else>...${paramNames}</#if>}
    dispatch({
      type: '${api?uncap_first}/${setupName()}',
      payload,
    })
  })
};
<#if api.route?contains("/$")>
    <#list api.inits as fun>
        <#assign path>${api.route?uncap_first?replace('/$','/:')}</#assign>
${api?uncap_first}Model.${fun}InitParamsFn = RouteUtil.getParams;
    </#list>
</#if>

${api?uncap_first}Model.effects.${setupName()} = function* ({payload}, {call, put, select}) {
  const appState = yield select(_ => _.app);
  const routeOpend = RouteUtil.isRouteOpend(appState.routeOrders, ${api?uncap_first}Model.pathname);
  if (!routeOpend) {
    return;
  }

  if (${api?uncap_first}Model.getInitState) {
    const initState = ${api?uncap_first}Model.getInitState();
    yield put(${api}Command.updateState_type(initState));
  }

  const newPayload = yield ${api}Command.${setupName()}_effect({payload}, {call, put, select});
  <#assign reducerName>${getReduceName(setupName(), true)}</#assign>
  yield put(${api}Command.${reducerName}_type(newPayload));
};

</#if>-->
<#list api.functions as fun>
  <#if fun.state.genEffect>

  /// ${fun.description}
  dynamic ${fun}(BuildContext context, <#if isEmptyList(fun.params)><#else><#if fun.json??>${fun.json}: ${genType(fun.json)}<#else>{Map<String, dynamic> payload, ${genTypeAndNames(fun.params,true)} }</#if></#if>) async {
    var newAreaState = await ${api}Command.${fun}(context<#if isNotEmptyList(fun.params)>, payload: payload, ${genParamsStr(fun.params)}</#if>);
    <#if fun.area??>
    var old${genArea(fun.area)?cap_first} = Provider.of<${api}State>(context).${genArea(fun.area)};
    old${genArea(fun.area)?cap_first}.merge(newAreaState);
    </#if>
    notifyListeners();
  }
  <#if fun.return.isPageList && fun.area??>

  dynamic ${nextEffectName(fun)}(BuildContext context) async {
    var newAreaState = await ${api}Command.${nextEffectName(fun)}(context);
      <#if fun.area??>
    var old${genArea(fun.area)?cap_first} = Provider.of<${api}State>(context).${genArea(fun.area)};
    old${genArea(fun.area)?cap_first}.merge(newAreaState);
      </#if>
    notifyListeners();
  }
  </#if>
  <#if fun.state.genRefresh>

  dynamic ${refreshEffectName(fun)}(BuildContext context) async {
    var newAreaState = await ${api}Command.${refreshEffectName(fun)}(context);
      <#if fun.area??>
    var old${genArea(fun.area)?cap_first} = Provider.of<${api}State>(context).${genArea(fun.area)};
    old${genArea(fun.area)?cap_first}.merge(newAreaState);
      </#if>
    notifyListeners();
  }
  </#if>
  </#if>
</#list>
}