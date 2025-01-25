;; Grid Balancing Contract

(define-map grid-status uint { demand: uint, supply: uint })
(define-map grid-imbalance uint uint)

(define-data-var current-period uint u0)
(define-data-var contract-owner principal tx-sender)

(define-public (update-grid-status (demand uint) (supply uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (map-set grid-status (var-get current-period) { demand: demand, supply: supply })
        (var-set current-period (+ (var-get current-period) u1))
        (ok true)
    )
)

(define-public (balance-grid)
    (let
        ((status (unwrap! (map-get? grid-status (- (var-get current-period) u1)) (err u404)))
         (imbalance (if (> (get demand status) (get supply status))
                           (- (get demand status) (get supply status))
                           (- (get supply status) (get demand status)))))
        (map-set grid-imbalance (- (var-get current-period) u1) imbalance)
        (ok true)
    )
)

(define-read-only (get-grid-status (period uint))
    (map-get? grid-status period)
)

(define-read-only (get-grid-imbalance (period uint))
    (ok (default-to u0 (map-get? grid-imbalance period)))
)

(define-read-only (get-current-period)
    (ok (var-get current-period))
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (ok (var-set contract-owner new-owner))
    )
)

(define-read-only (get-contract-owner)
    (ok (var-get contract-owner))
)

