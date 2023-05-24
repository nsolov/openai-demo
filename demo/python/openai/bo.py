
from grongier.pex import BusinessOperation
import openai
import os
from gptresponsemessage import GPTResponseMessage


class GPTOperation(BusinessOperation):
    """
    This operation receive a GPTMessage and make a request to ChatGPT
    """

    APIKey = str()

    def on_init(self):
        if hasattr(self,'path'):
            os.chdir(self.path)

    def on_message(self, request):
        openai.api_key = self.APIKey

        self.LOGINFO('request: ' + request.content)

        messages = [
            {"role": "system", "content": "You are a helpful travel assistant."},
            {"role": "user", "content": request.content}
        ]

        res = None
        try:
            airesponse = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=messages,
                temperature=0.5,
                max_tokens=600,
                stop=None,
                frequency_penalty=0.0,
                presence_penalty=0.0
            )
            self.LOGINFO('response: ' + airesponse.choices[0]['message']['content'])
            text = airesponse.choices[0]['message']['content']

            airports = None
            """
            messages = [
                {"role": "system", "content": "You are a helpful travel assistant."},
                {"role": "user", "content": request.content},
                {"role": "assistant", "content": text},
                {"role": "user", "content": "Indicate the codes of the airports closest to the resorts you suggested. The answer must contain only three-letter codes separated by commas."}
            ]

            airesponse = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=messages,
                temperature=0.5,
                max_tokens=600,
                stop=None,
                frequency_penalty=0.0,
                presence_penalty=0.0
            )
            self.LOGINFO('response: ' + airesponse.choices[0]['message']['content'])
            airports = airesponse.choices[0]['message']['content']
            """

            res = GPTResponseMessage(text, None)
        except openai.error.AuthenticationError:
            res = GPTResponseMessage(None, 'OpenAI AuthenticationError')
            self.LOGERROR('AuthenticationError')
        except Exception as e:
            res = GPTResponseMessage(None, 'OpenAI '+str(e))
            self.LOGERROR('Something went wrong ' + str(e))
        return res


