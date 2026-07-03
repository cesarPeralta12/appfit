<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MessageThread;
use Illuminate\Http\Request;

class MessageThreadController extends Controller
{
    public function index(Request $request)
    {
        $threads = MessageThread::where('coach_id', $request->user()->id)
            ->with('student', 'messages')
            ->orderByDesc('updated_at')
            ->get();

        return response()->json($threads);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'student_id' => 'nullable|exists:students,id',
            'is_announcement' => 'boolean',
            'title' => 'nullable|string',
            'body' => 'required|string',
        ]);

        $thread = MessageThread::create([
            'coach_id' => $request->user()->id,
            'student_id' => $data['student_id'] ?? null,
            'is_announcement' => $data['is_announcement'] ?? false,
            'title' => $data['title'] ?? null,
        ]);

        $thread->messages()->create([
            'sender_id' => $request->user()->id,
            'body' => $data['body'],
        ]);

        return response()->json($thread->load('messages'), 201);
    }

    public function show(Request $request, string $id)
    {
        $thread = MessageThread::where('coach_id', $request->user()->id)
            ->with('messages.sender', 'student')
            ->findOrFail($id);

        return response()->json($thread);
    }

    public function reply(Request $request, string $id)
    {
        $thread = MessageThread::where('coach_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate(['body' => 'required|string']);

        $message = $thread->messages()->create([
            'sender_id' => $request->user()->id,
            'body' => $data['body'],
        ]);

        return response()->json($message, 201);
    }

    public function destroy(Request $request, string $id)
    {
        MessageThread::where('coach_id', $request->user()->id)->findOrFail($id)->delete();

        return response()->json(['message' => 'Conversacion eliminada']);
    }
}
