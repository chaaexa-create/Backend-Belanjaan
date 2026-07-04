<?php

namespace App\Events;

use App\Models\Barang;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class BarangEvent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Barang $barang,
        public string $action,
    ) {
        //
    }

    public function broadcastOn(): array
    {
        return [
            new Channel('shopping-channel'),
        ];
    }

    public function broadcastAs(): string
    {
        return 'barang.event';
    }

    public function broadcastWith(): array
    {
        return [
            'action' => $this->action,
            'data' => $this->barang->only('id', 'nama_barang', 'harga_final', 'is_dibeli'),
        ];
    }
}
