"""
ColdAI — Güven Skoru ve OOD (Out-of-Distribution) Tespiti

Modelin bilinmeyen nesnelere saçma tahminler vermesini önler.
Üç strateji kullanılır:
  1. Softmax Thresholding — En yüksek olasılık eşik altındaysa → belirsiz
  2. Top-2 Gap — İlk iki tahmin arasındaki fark çok küçükse → kararsız
  3. Entropi (opsiyonel) — Dağılım çok düzse → model emin değil
"""

import numpy as np
from backend.config import TOP2_GAP_THRESHOLD


def check_confidence(
    probabilities: np.ndarray,
    threshold: float,
    top2_gap_threshold: float = TOP2_GAP_THRESHOLD,
) -> tuple[bool, float, str]:
    """
    Çok katmanlı güven kontrolü.

    Args:
        probabilities: Softmax çıktı vektörü (1D array)
        threshold: Minimum kabul edilebilir güven skoru
        top2_gap_threshold: İlk iki tahmin arası minimum fark

    Returns:
        (is_confident, max_probability, reason)
        - is_confident: Tahminin güvenilir olup olmadığı
        - max_probability: En yüksek softmax olasılığı
        - reason: Kararın kısa açıklaması
    """
    flat = probabilities.flatten()
    max_prob = float(np.max(flat))

    # Strateji 1: Direkt eşik kontrolü
    if max_prob < threshold:
        return (
            False,
            max_prob,
            f"Düşük güven: {max_prob:.3f} < {threshold}",
        )

    # Strateji 2: Top-2 farkı kontrolü
    if len(flat) >= 2:
        sorted_probs = np.sort(flat)[::-1]
        top2_gap = sorted_probs[0] - sorted_probs[1]
        if top2_gap < top2_gap_threshold:
            return (
                False,
                max_prob,
                f"Belirsiz tahmin: top-2 fark {top2_gap:.3f} < {top2_gap_threshold}",
            )

    return (True, max_prob, "Güvenilir tahmin")


def compute_entropy(probabilities: np.ndarray) -> float:
    """
    Softmax dağılımının Shannon entropisini hesapla.

    Yüksek entropi → model emin değil (dağılım düz)
    Düşük entropi → model emin (bir sınıfa yoğunlaşmış)

    Args:
        probabilities: Softmax çıktı vektörü

    Returns:
        Entropi değeri (bit)
    """
    flat = probabilities.flatten()
    # Sıfır değerleri filtrele (log(0) undefined)
    flat = flat[flat > 0]
    return float(-np.sum(flat * np.log2(flat)))
