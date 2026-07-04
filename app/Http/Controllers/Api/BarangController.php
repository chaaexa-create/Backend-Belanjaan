<?php

namespace App\Http\Controllers\Api;

use App\Events\BarangEvent;
use App\Http\Controllers\Controller;
use App\Models\Barang;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BarangController extends Controller
{
    public function index(): JsonResponse
    {
        $barangs = Barang::latest()->get();

        return response()->json([
            'success' => true,
            'data' => $barangs,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama_barang' => 'required|string|max:255',
            'harga_final' => 'nullable|numeric|min:0',
        ]);

        if ($request->has('harga_final')) {
            $validated['is_dibeli'] = true;
        }

        $barang = Barang::create($validated);

        BarangEvent::dispatch($barang, 'CREATED');

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil ditambahkan',
            'data' => $barang,
        ], 201);
    }

    public function update(Request $request, Barang $barang): JsonResponse
    {
        $validated = $request->validate([
            'nama_barang' => 'sometimes|string|max:255',
        ]);

        $barang->update($validated);

        BarangEvent::dispatch($barang->fresh(), 'UPDATED');

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil diperbarui',
            'data' => $barang,
        ]);
    }

    public function toggleStatus(Request $request, Barang $barang): JsonResponse
    {
        $validated = $request->validate([
            'is_dibeli' => 'required|boolean',
            'harga_final' => 'nullable|numeric|min:0|required_if:is_dibeli,1',
        ]);

        $barang->is_dibeli = $validated['is_dibeli'];
        $barang->harga_final = $validated['is_dibeli'] ? $validated['harga_final'] : null;
        $barang->save();

        BarangEvent::dispatch($barang->fresh(), 'UPDATED');

        return response()->json([
            'success' => true,
            'message' => $barang->is_dibeli ? 'Barang ditandai sudah dibeli' : 'Barang ditandai belum dibeli',
            'data' => $barang,
        ]);
    }

    public function destroy(Barang $barang): JsonResponse
    {
        $barang->delete();

        BarangEvent::dispatch($barang, 'DELETED');

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil dihapus',
        ]);
    }
}
