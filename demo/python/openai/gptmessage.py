from grongier.pex import Message

from dataclasses import dataclass

from obj import PostClass

@dataclass
class GPTMessage(Message):
    content:str = None
