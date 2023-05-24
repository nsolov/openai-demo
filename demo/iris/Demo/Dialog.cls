Class Demo.Dialog Extends %Persistent
{

Property ChatId As %Integer;

Property UserName As %String;

Property DateStart As %PosixTime;

Property Next As %String;

Property City As %String;

Property What1 As %String;

Property What2 As %String;

Property What3 As %String;

Property Days As %String;

Property Where As %String;

Property Time As %String;

Index ChatIdIndex On ChatId [ Unique ];

Method getPrompt() As %String
{
    set str = "Please suggest 3 vacation options. "
    set str = str _ ..UserName_ " lives in "_..City_", and wants to go on vacation for "_..Days_" days."
    set str = str _ ..UserName_ " prefers "_..What1_" vacations, the most important on vacation is "_..What2_", "
    set str = str _ "also likes  "_..What3_"."
    set str = str _ " Maximum flight time to destination is "_..Time_" hours"
    return str
}

Method saveStep(data As %DynamicObject) As %Status
{
    set steps = $LB("City","What1","What2","What3","Days","Where","Time")
    set text = data."message"."text"

    if ($listfind(steps,..Next)) {
        set $PROPERTY($this, ..Next) = $ZSTRIP($PROPERTY($this, ..Next)_" "_text,"<>W")
        do ..setNextStep()
        return ..%Save()
    }
    return $$$OK
}

Method setNextStep()
{
    if ( ..Next = "City" ) {
        set ..Next = "What1"
    } elseif ( ..Next = "What1") {
        set ..Next = "What2"
    } elseif ( ..Next = "What2") {
        set ..Next = "What3"
    } elseif ( ..Next = "What3") {
        set ..Next = "Days"
    } elseif ( ..Next = "Days") {
    //    set ..Next = "Where"
    //} elseif ( ..Next = "Where") {
        set ..Next = "Time"
    } elseif ( ..Next = "Time") {
        set ..Next = "GPT"
    }
}

Method getNextStepText() As %String
{
    set steps("City","text") = "Welcome "_..UserName_"! "_$$$NL_"I will help you find the right place for your vacation. To do this, first answer a few questions. "_$$$NL_$$$NL_"1.Where do you live (write the name of the city)?"
    set steps("What1","text") = "2. What kind of vacation do you prefer? (Choose one)"
    set steps("What2","text") = "3. What is the most important thing for you during vacation? (Choose one)"
    set steps("What3","text") = "4. What else is important to you? (Write your own option)"
    set steps("Days","text") = "5. How many days would you like to travel?"
    //set steps("Where","text") = "Would you like to travel within the country or abroad?"
    set steps("Time","text") = "6. How much time do you want to spend on the flight (maximum time, hours)?"

    set steps("GPT","text") = "... Wait for the request to be completed ..."

    set steps("END","text") = "... Start a new search with the /start command ..."

    return steps(..Next,"text")
}

Method getStepTGData() As %DynamicObject
{
    if (..Next = "What1") {
        set res = {
            "text": (..getNextStepText()),
            "one_time_keyboard": true,
            "reply_markup": {
                "keyboard": [[{"text":"Sightseeing"},{"text":"Beach"}],[{"text":"Health and SPA"},{"text":"Skiing"}],[{"text":"Sea cruises"},{"text":"Active recreation"}]]
            }
        }
    } elseif (..Next = "What2") {
        set res = {
            "text": (..getNextStepText()),
            "one_time_keyboard": true,
            "reply_markup": {
                "keyboard": [[{"text":"Sandy beach"},{"text":"Peace and tranquility"}],[{"text":"Night Clubs & Bars"},{"text":"Large water park"}],[{"text":"Educational excursions"},{"text":"Delicious food"}]]
            }
        }
    } else {
        set res = {
            "text": (..getNextStepText()),
            "reply_markup": {"remove_keyboard": true }
        }
    }
    return res
}

ClassMethod CreateDialog(data As %DynamicObject) As %Status
{
    set chatId = data."message"."chat"."id"
    do ..DeteleByChatId(chatId)

    set di = ..%New()
    set di.ChatId = chatId
    set di.UserName = data."message"."chat"."first_name"
    set di.DateStart = ##class(%PosixTime).CurrentUTCTimeStamp(6)
    set di.Next = "City"
    do di.%Save()
    return di
}

ClassMethod DeteleByChatId(chatId) As %Status
{
    &sql(DELETE FROM Telegram_Demo.Dialog WHERE ChatId = :chatId)
    return $$$OK
}

Storage Default
{
<Data name="DialogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ChatId</Value>
</Value>
<Value name="3">
<Value>UserName</Value>
</Value>
<Value name="4">
<Value>DateStart</Value>
</Value>
<Value name="5">
<Value>City</Value>
</Value>
<Value name="6">
<Value>Next</Value>
</Value>
<Value name="7">
<Value>What1</Value>
</Value>
<Value name="8">
<Value>What2</Value>
</Value>
<Value name="9">
<Value>A</Value>
</Value>
<Value name="10">
<Value>Not</Value>
</Value>
<Value name="11">
<Value>Days</Value>
</Value>
<Value name="12">
<Value>Where</Value>
</Value>
<Value name="13">
<Value>Time</Value>
</Value>
<Value name="14">
<Value>What3</Value>
</Value>
</Data>
<DataLocation>^Telegram.Demo.DialogD</DataLocation>
<DefaultData>DialogDefaultData</DefaultData>
<IdLocation>^Telegram.Demo.DialogD</IdLocation>
<IndexLocation>^Telegram.Demo.DialogI</IndexLocation>
<StreamLocation>^Telegram.Demo.DialogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
