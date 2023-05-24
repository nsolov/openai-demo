Class Demo.GPTMessage Extends Ens.Request
{

Property content As %String(MAXLEN = 10000);

Storage Default
{
<Data name="GPTMessageDefaultData">
<Subscript>"GPTMessage"</Subscript>
<Value name="1">
<Value>content</Value>
</Value>
</Data>
<DefaultData>GPTMessageDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
