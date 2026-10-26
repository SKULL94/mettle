from typing import Any

from langgraph.graph import END, START, StateGraph

from .nodes import ask_question, await_answer, grade_answer, plan_interview, summarize
from .state import InterviewState


def route_after_grade(state: InterviewState) -> str:
    if state["probe"]:
        return "ask_question"
    if state["questions_remaining"] > 0:
        return "ask_question"
    return "summarize"


def build_graph(checkpointer: Any) -> Any:
    graph: StateGraph = StateGraph(InterviewState)

    graph.add_node("plan_interview", plan_interview)
    graph.add_node("ask_question", ask_question)
    graph.add_node("await_answer", await_answer)
    graph.add_node("grade_answer", grade_answer)
    graph.add_node("summarize", summarize)

    graph.add_edge(START, "plan_interview")
    graph.add_edge("plan_interview", "ask_question")
    graph.add_edge("ask_question", "await_answer")
    graph.add_edge("await_answer", "grade_answer")
    graph.add_conditional_edges(
        "grade_answer",
        route_after_grade,
        ["ask_question", "summarize"],
    )
    graph.add_edge("summarize", END)

    return graph.compile(checkpointer=checkpointer)
