extends Resource
class_name  QuestionBank
@export var questions : Array[QuestionData] =[]

func get_count() -> int:
	return questions.size()

func get_question(i: int) -> QuestionData:
	if i < 0 or i >= questions.size():
		return null
	return questions[i]
