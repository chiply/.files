# Description

I'm trying to create an architecture where I can define agents and make those available to a central LLM that coordinates everything amongst those agents.

And I want the agents themselves to consist of both models as well as tools, and as such those agents are essentially going to constitute specialists or experts for certain prompts.

The idea is that you prompt the central LLM, the LLM identifies what is the best specialist agent for the task, it routes your request to the agent best suited for the task, and then the agent responds with the answer.

I like what this enables as it would allow you to build a diverse set of specialists easily using FastMCP, and this can easily be made configuration driven.

The implementation is that I'm defining 1 FastMCP (https://github.com/jlowin/fastmcp) server per specialist, and each server uses langchain (https://github.com/langchain-ai/langchain) to define an agent that consists of a model and a set of tools.  Tools can be defined in python, but I'm opening up to the universe of freely available MCP servers by using adapters (https://github.com/langchain-ai/langchain-mcp-adapters).

In the editor, a main agent is used, where a main LLM can be selected using gptel (https://github.com/karthink/gptel), and this LLM can be connected to the MCP servers (specialists) described above. 


# Notes
I was able to get the adapter to work on its own, not using it as an MCP.

I'm stuck trying to get the special agent (Claude/openai) to query the MCP server (fetch) that I'm giving it access to.  LEFTOFF try getting the specialist working without access to another MCP server.

NOTE possible issue?: the MCP -- LLM interface communicates what tools are available.... So an issue here could be that I'm implementing a main LLM --> specialist LLM --> MCP server, and I think the main LLM is not aware of the actualy tools that the specialist's MCP server has access to.

This seems to be the last ingredient, although there is a level of translation happening between the main LLM and the specialist LLM, may need to add a system prompt
