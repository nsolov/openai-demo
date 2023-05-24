Class Demo.TGBusinessService Extends Ens.BusinessService
{

Parameter ADAPTER = "Telegram.InboundAdapter";

Property Target;

Parameter SETTINGS = "Target:Demo:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
    If (..Target = "") {
        Return $$$ERROR(5001, "Target property required")
    }
    Set msg = ##class(Telegram.JSONContainer).%New(pInput)
    $$$TRACE(msg.Data.%ToJSON())
    Return ..SendRequestAsync(..Target, msg)
}

}
