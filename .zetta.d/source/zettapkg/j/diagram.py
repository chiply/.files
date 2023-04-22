from diagrams import Diagram
from diagrams.c4 import Person, Container, Database, System, SystemBoundary, Relationship

graph_attr = {
    "splines": "spline",
}

with Diagram("x", direction="LR", graph_attr=graph_attr):
    # nodes
    default_target_template_values = Container(name="default_target_template_values", description="")
    dynamic_target_template_values = Container(name="dynamic_target_template_values", description="")
    target_template_values = Container(name="target_template_values", description="")
    configuration_ui = Container(name="configuration_ui", description="")
    target_templates = Container(name="target_templates", description="")
    target_renderer = Container(name="target_renderer", description="")
    executor = Container(name="executor", description="")
    target_selector = Container(name="target_selector", description="")
    clipboard = Container(name="clipboard", description="")
    target_db = Container(name="target_db", description="")

    # edges
    default_target_template_values >> Relationship("inherited by") >> target_template_values
    dynamic_target_template_values >> Relationship("") >> target_template_values
    target_templates >> Relationship("template input") >> target_renderer
    target_template_values >> Relationship("values input") >> target_renderer
    configuration_ui >> Relationship("modifies values in") >> target_template_values
    target_renderer >> Relationship("sends targets to") >> executor
    target_renderer >> Relationship("sends targets to") >> target_db
    target_selector >> Relationship("sends targets to ") >> clipboard
    target_selector >> Relationship("sends targets to") >> executor
    target_selector >> Relationship("pulls targets from") >> target_db

