using Godot;
using System;

[GlobalClass]
public partial class DialogueManager : Node
{
	public Control DialogueBox { get; set; }

	public override void _Ready()
	{
		
	}
	
	public void Test()
	{
		GD.Print("Ayo!");
	}
}
