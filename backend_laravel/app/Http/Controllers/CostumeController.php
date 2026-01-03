<?php

namespace App\Http\Controllers;

use App\Models\Costume;
use Illuminate\Http\Request;

class CostumeController extends Controller
{
    public function index()
    {
        $costumes = Costume::orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'data' => $costumes,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'imageUrl' => 'required|string',
            'sellerId' => 'required|string',
        ]);

        $costume = Costume::create([
            'description' => $request->description,
            'price' => $request->price,
            'image_url' => $request->imageUrl,
            'seller_id' => $request->sellerId,
            'is_reserved' => false,   // 🔥 Nouveau
            'created_at' => $request->createdAt ?? now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'data' => $costume,
            'message' => 'Costume créé avec succès',
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $costume = Costume::findOrFail($id);

        if ($costume->seller_id != $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé',
            ], 403);
        }

        $request->validate([
            'description' => 'sometimes|required|string',
            'price' => 'sometimes|required|numeric|min:0',
            'imageUrl' => 'sometimes|required|string',
            'is_reserved' => 'sometimes|boolean',   // 🔥 Nouveau
        ]);

        $costume->update([
            'description' => $request->description ?? $costume->description,
            'price' => $request->price ?? $costume->price,
            'image_url' => $request->imageUrl ?? $costume->image_url,
            'is_reserved' => $request->is_reserved ?? $costume->is_reserved,  // 🔥 Nouveau
            'updated_at' => now(),
        ]);

        return response()->json([
            'data' => $costume,
            'message' => 'Costume mis à jour avec succès',
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $costume = Costume::findOrFail($id);

        if ($costume->seller_id != $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé',
            ], 403);
        }

        $costume->delete();

        return response()->json([
            'message' => 'Costume supprimé avec succès',
        ], 200);
    }

    public function search(Request $request)
    {
        $query = $request->query('q', '');

        if (empty($query)) {
            return $this->index();
        }

        $costumes = Costume::where('description', 'LIKE', "%{$query}%")
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $costumes,
        ]);
    }

    public function getBySeller(Request $request, $sellerId)
    {
        if ($sellerId != $request->user()->id) {
            return response()->json([
                'message' => 'Non autorisé',
            ], 403);
        }

        $costumes = Costume::where('seller_id', $sellerId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $costumes,
        ]);
    }
    public function reserve(Request $request, $id)
{
    $costume = Costume::findOrFail($id);
    $costume->is_reserved = true;
    $costume->save();

    return response()->json([
        'message' => 'Costume réservé avec succès',
        'data' => $costume
    ], 200);
}

}
