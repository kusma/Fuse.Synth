using Fuse.Triggers.Actions;

namespace Fuse.Synth
{
	public class NoteOn : TriggerAction
	{
		public Synth Target { get; set; }
		public int Note { get; set; }
		
		protected override void Perform(Node target)
		{
			debug_log "NoteOn: " + Note;
			if (Target != null)
				Target.NoteOn(Note);
		}
	}
}
