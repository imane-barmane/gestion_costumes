<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImageController extends Controller
{
    public function upload(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $filename = time() . '_' . $image->getClientOriginalName();
            $path = $image->storeAs('costumes', $filename, 'public');

            $imageUrl = Storage::url($path);
            
            // Retourner l'URL complète
            $fullUrl = url($imageUrl);

            return response()->json([
                'image_url' => $fullUrl,
                'message' => 'Image uploadée avec succès',
            ]);
        }

        return response()->json([
            'message' => 'Aucune image fournie',
        ], 400);
    }
}

