Class Demo.TGProcess Extends Ens.BusinessProcess
{

Property ChatId As %Integer;

Method OnRequest(request As Telegram.JSONContainer, Output response As %Library.Persistent) As %Status
{
    set data = request.Data
    set ..ChatId = data."message"."chat"."id"
    set dialog = ##class(Demo.Dialog).ChatIdIndexOpen(..ChatId)

    if ( ( '$isobject(dialog) ) || ( data."message"."text" = "/start" ) ) {
        // create dialog
        $$$TRACE("new")
        set dialog = ##class(Demo.Dialog).CreateDialog(data)
    } else {
        $$$TRACE("$$"_data."message"."text"_"%%")
        $$$TRACE("save")
        do dialog.saveStep(data)
    }

    $$$TRACE(dialog.Next_dialog.City)

    if (dialog.Next="GPT") {
        // to GPT
        set msg = ##class(Demo.GPTMessage).%New()
        set msg.content = dialog.getPrompt()
        $$$TRACE(msg.content)
        do ..SendRequestAsync("Python.GPTOperation",msg,1,"gpt")


        set tgreq = ##class(Telegram.Request).%New()
        set tgreq.Method = "sendMessage"
        set tgreq.Data = {
            "chat_id": (..ChatId),
            "text": ("Please wait we will find something for you ...")
        }
        do ..SendRequestAsync("Telegram.BusinessOperation",tgreq)


        set dialog.Next = "END"
        do dialog.%Save()
    } else {
        set data = dialog.getStepTGData()
        set data."chat_id" = ..ChatId
        set tgreq = ##class(Telegram.Request).%New()
        set tgreq.Method = "sendMessage"
        set tgreq.Data = data
        do ..SendRequestAsync("Telegram.BusinessOperation",tgreq)
    }
    return $$$OK
}

Method OnResponse(request As %Library.Persistent, ByRef response As %Library.Persistent, callrequest As %Library.Persistent, callresponse As %Library.Persistent, pCompletionKey As %String) As %Status
{
    if (pCompletionKey="gpt") {
        set jo = {}.%FromJSON(callresponse.jsonGet())

        set tgreq = ##class(Telegram.Request).%New()
        set tgreq.Method = "sendMessage"

        if (jo.error'="") {
            set text = "An error occurred while accessing openai: "_jo.error
        } elseif (jo.responseString'="") {
            set text = jo.responseString
        } else {
            set text = "Unknown error while processing request"
        }
        set tgreq.Data = {
            "chat_id": (..ChatId),
            "text": (text)
        }
        do ..SendRequestAsync("Telegram.BusinessOperation",tgreq)
    }
    return $$$OK
}

Storage Default
{
<Data name="TGProcessDefaultData">
<Subscript>"TGProcess"</Subscript>
<Value name="1">
<Value>ChatId</Value>
</Value>
</Data>
<DefaultData>TGProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
