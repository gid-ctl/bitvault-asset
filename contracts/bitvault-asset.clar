;; BitVault - Bitcoin-Native Asset Tokenization Protocol
;;
;; Transform real-world assets into fractional Bitcoin-secured tokens with
;; institutional-grade compliance and transparency built for Stacks Layer 2
;;
;; BitVault revolutionizes asset ownership by bridging traditional finance
;; with Bitcoin's security model, enabling fractional ownership of premium
;; assets while maintaining regulatory compliance and transparent governance.
;;
;; Core Value Propositions:
;; - Bitcoin-secured fractional asset ownership with institutional compliance
;; - Transparent on-chain governance with automated compliance verification
;; - Seamless fractional trading with built-in regulatory safeguards
;; - Enterprise-grade audit trails and event logging for regulatory reporting
;; - Native Stacks integration leveraging Bitcoin's security and finality
;;
;; Perfect for: Real estate tokenization, art collections, precious metals,
;; intellectual property, and any high-value asset requiring compliant
;; fractional ownership on Bitcoin's most secure Layer 2 solution.

;; PROTOCOL CONSTANTS & ERROR DEFINITIONS

(define-constant CONTRACT-OWNER tx-sender)
(define-constant CONTRACT-ADMIN CONTRACT-OWNER)

;; Error Constants - Comprehensive error handling for enterprise use
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-ASSET (err u3))
(define-constant ERR-TRANSFER-FAILED (err u4))
(define-constant ERR-COMPLIANCE-CHECK-FAILED (err u5))
(define-constant ERR-INVALID-INPUT (err u6))
(define-constant ERR-INSUFFICIENT-SHARES (err u7))
(define-constant ERR-EVENT-LOGGING (err u8))

;; PROTOCOL STATE VARIABLES

;; Global asset counter for unique asset identification
(define-data-var next-asset-id uint u1)

;; CORE DATA STRUCTURES

;; Primary asset registry - stores comprehensive asset metadata
(define-map asset-registry
  { asset-id: uint }
  {
    owner: principal,
    total-supply: uint,
    fractional-shares: uint,
    metadata-uri: (string-utf8 256),
    is-transferable: bool,
    created-at: uint,
  }
)

;; Compliance management system - tracks regulatory approval status
(define-map compliance-status
  {
    asset-id: uint,
    user: principal,
  }
  {
    is-approved: bool,
    last-updated: uint,
    approved-by: principal,
  }
)

;; Fractional ownership tracking - manages share distribution
(define-map share-ownership
  {
    asset-id: uint,
    owner: principal,
  }
  { shares: uint }
)

;; NFT TOKEN DEFINITION

;; Primary ownership token representing asset control rights
(define-non-fungible-token asset-ownership-token uint)

;; AUDIT TRAIL & EVENT SYSTEM

;; Event counter for comprehensive audit logging
(define-data-var last-event-id uint u0)

;; Immutable event log for regulatory compliance and transparency
(define-map events
  { event-id: uint }
  {
    event-type: (string-utf8 24),
    asset-id: uint,
    principal1: principal,
    timestamp: uint,
  }
)

;; PRIVATE UTILITY FUNCTIONS

;; Event logging system for comprehensive audit trails
(define-private (log-event
    (event-type (string-utf8 24))
    (asset-id uint)
    (principal1 principal)
  )
  (begin
    (let ((event-id (+ (var-get last-event-id) u1)))
      (map-set events { event-id: event-id } {
        event-type: event-type,
        asset-id: asset-id,
        principal1: principal1,
        timestamp: stacks-block-height,
      })
      (var-set last-event-id event-id)
      (ok event-id)
    )
  )
)

;; INPUT VALIDATION FUNCTIONS

;; Validates metadata URI format and length constraints
(define-private (is-valid-metadata-uri (uri (string-utf8 256)))
  (and
    (> (len uri) u0)
    (<= (len uri) u256)
    (> (len uri) u5)
  )
)

;; Validates asset ID exists within system bounds
(define-private (is-valid-asset-id (asset-id uint))
  (and
    (> asset-id u0)
    (< asset-id (var-get next-asset-id))
  )
)

;; Validates principal addresses for security compliance
(define-private (is-valid-principal (user principal))
  (and
    (not (is-eq user CONTRACT-OWNER))
    (not (is-eq user (as-contract tx-sender)))
  )
)

;; Compliance verification - checks regulatory approval status
(define-private (is-compliance-check-passed
    (asset-id uint)
    (user principal)
  )
  (match (map-get? compliance-status {
    asset-id: asset-id,
    user: user,
  })
    compliance-data (get is-approved compliance-data)
    false
  )
)

;; SHARE MANAGEMENT UTILITIES

;; Retrieves current share balance for asset-owner pair
(define-private (get-shares
    (asset-id uint)
    (owner principal)
  )
  (default-to u0
    (get shares
      (map-get? share-ownership {
        asset-id: asset-id,
        owner: owner,
      })
    ))
)

;; Updates share balance in ownership registry
(define-private (set-shares
    (asset-id uint)
    (owner principal)
    (amount uint)
  )
  (map-set share-ownership {
    asset-id: asset-id,
    owner: owner,
  } { shares: amount }
  )
)

;; PUBLIC PROTOCOL FUNCTIONS

;; Creates new tokenized asset with fractional ownership capabilities
(define-public (create-asset
    (total-supply uint)
    (fractional-shares uint)
    (metadata-uri (string-utf8 256))
  )
  (begin
    ;; Input validation with comprehensive checks
    (asserts! (> total-supply u0) ERR-INVALID-INPUT)
    (asserts! (> fractional-shares u0) ERR-INVALID-INPUT)
    (asserts! (<= fractional-shares total-supply) ERR-INVALID-INPUT)
    (asserts! (is-valid-metadata-uri metadata-uri) ERR-INVALID-INPUT)

    (let ((asset-id (var-get next-asset-id)))
      ;; Register asset in primary registry
      (map-set asset-registry { asset-id: asset-id } {
        owner: tx-sender,
        total-supply: total-supply,
        fractional-shares: fractional-shares,
        metadata-uri: metadata-uri,
        is-transferable: true,
        created-at: stacks-block-height,
      })

      ;; Initialize creator's full ownership
      (set-shares asset-id tx-sender total-supply)

      ;; Mint primary ownership NFT and log creation event
      (unwrap! (nft-mint? asset-ownership-token asset-id tx-sender)
        ERR-TRANSFER-FAILED
      )
      (unwrap! (log-event u"ASSET_CREATED" asset-id tx-sender) ERR-EVENT-LOGGING)

      ;; Increment global asset counter
      (var-set next-asset-id (+ asset-id u1))
      (ok asset-id)
    )
  )
)

;; Transfers fractional ownership with compliance verification
(define-public (transfer-fractional-ownership
    (asset-id uint)
    (to-principal principal)
    (amount uint)
  )
  (let (
      (asset (unwrap! (map-get? asset-registry { asset-id: asset-id }) ERR-INVALID-ASSET))
      (sender tx-sender)
      (sender-shares (get-shares asset-id sender))
    )
    ;; Comprehensive pre-transfer validation
    (asserts! (is-valid-asset-id asset-id) ERR-INVALID-INPUT)
    (asserts! (is-valid-principal to-principal) ERR-INVALID-INPUT)
    (asserts! (get is-transferable asset) ERR-UNAUTHORIZED)
    (asserts! (is-compliance-check-passed asset-id to-principal)
      ERR-COMPLIANCE-CHECK-FAILED
    )
    (asserts! (>= sender-shares amount) ERR-INSUFFICIENT-SHARES)

    ;; Execute atomic share transfer
    (set-shares asset-id sender (- sender-shares amount))
    (set-shares asset-id to-principal
      (+ (get-shares asset-id to-principal) amount)
    )

    ;; Log transfer for audit trail
    (unwrap! (log-event u"TRANSFER" asset-id sender) ERR-EVENT-LOGGING)

    ;; Transfer primary NFT if full ownership transferred
    (if (is-eq sender-shares amount)
      (unwrap! (nft-transfer? asset-ownership-token asset-id sender to-principal)
        ERR-TRANSFER-FAILED
      )
      true
    )

    (ok true)
  )
)

;; Updates compliance status for regulatory management
(define-public (set-compliance-status
    (asset-id uint)
    (user principal)
    (is-approved bool)
  )
  (begin
    ;; Administrative access control
    (asserts! (is-valid-asset-id asset-id) ERR-INVALID-INPUT)
    (asserts! (is-valid-principal user) ERR-INVALID-INPUT)
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)

    ;; Update compliance registry
    (map-set compliance-status {
      asset-id: asset-id,
      user: user,
    } {
      is-approved: is-approved,
      last-updated: stacks-block-height,
      approved-by: tx-sender,
    })

    ;; Log compliance update for audit
    (unwrap! (log-event u"COMPLIANCE_UPDATE" asset-id user) ERR-EVENT-LOGGING)

    (ok is-approved)
  )
)

;; READ-ONLY QUERY FUNCTIONS

;; Retrieves comprehensive asset details
(define-read-only (get-asset-details (asset-id uint))
  (map-get? asset-registry { asset-id: asset-id })
)

;; Returns fractional ownership balance for specific owner
(define-read-only (get-owner-shares
    (asset-id uint)
    (owner principal)
  )
  (ok (get-shares asset-id owner))
)

;; Retrieves compliance status and history
(define-read-only (get-compliance-details
    (asset-id uint)
    (user principal)
  )
  (map-get? compliance-status {
    asset-id: asset-id,
    user: user,
  })
)

;; Accesses immutable event log for audit purposes
(define-read-only (get-event (event-id uint))
  (map-get? events { event-id: event-id })
)
