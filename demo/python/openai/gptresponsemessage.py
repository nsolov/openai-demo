from grongier.pex import Message

from dataclasses import dataclass

from obj import PostClass

@dataclass
class GPTResponseMessage(Message):
    def __init__(self, text=None, error=None):
        super().__init__()
        self.responseString = text
        self.error = error