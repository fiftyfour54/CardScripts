--透幻郷の銀嶺
--The Snow-Capped Summit of Spectral Shangri-La
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcond)
	c:RegisterEffect(e1)
	--double tribute
	local e2=s.summonproc(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end

function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(aux.FilterFaceupFunction(Card.IsLevelAbove,7),e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)>0
end
function s.summonproc(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SUMMON_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSummonCondition1(min,max,f))
		e1:SetTarget(Auxiliary.NormalSummonTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSummonOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSummonCondition2())
	end
	e1:SetValue(val)
	return e1
end
function s.otfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsRace(RACE_WYRM) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
function s.con(min,max,f)
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		local mg=Duel.GetTributeGroup(c)
		mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg=mg:Filter(f,nil,tp)
		end
		return minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
	end
end
function s.tg(min,max,f)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		local mg=Duel.GetTributeGroup(c)
		mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg=mg:Filter(f,nil,tp)
		end
		local g=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.GetCurrentChain()==0)
		if g and #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end
function s.op(min,max,sumop)
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
		if sumop then
			sumop(g:Clone(),e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		end
		g:DeleteGroup()
	end
end
