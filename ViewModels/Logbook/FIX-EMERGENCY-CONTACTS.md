# 🚨 FIX URGENTE: Contatti di Emergenza - Campo Email Mancante

## Problema Identificato

L'app iOS sta cercando di salvare e visualizzare i campi `email` e `notes` per i contatti di emergenza, ma il **backend WordPress NON li gestisce**.

### Cosa succede ora:
1. ✅ L'app salva correttamente `name`, `phone`, `relationship`
2. ❌ L'app invia `email` e `notes` ma il backend li ignora
3. ❌ Quando l'app ricarica i dati, `email` e `notes` sono sempre `null`

### Prova dal Debug
Nel console log dovresti vedere:
```
📞 Emergency Contacts: 1
  - Mirko Achermann | +41796636610
    relationship: Amico/a
    email: nil  ❌ Questo è il problema!
```

---

## Soluzione Backend WordPress

### File da modificare: `class-sd-diver-profile.php`

Cerca la funzione `save_emergency_contact()` (circa riga 243) e modifica:

#### PRIMA (codice attuale):
```php
public function save_emergency_contact() {
    check_ajax_referer( 'sd_profile_nonce', 'nonce' );
    $user_id  = get_current_user_id();
    $contacts = get_user_meta( $user_id, 'sd_emergency_contacts', true ) ?: array();

    $new = array(
        'name'         => sanitize_text_field( $_POST['contact_name'] ?? '' ),
        'phone'        => sanitize_text_field( $_POST['contact_phone'] ?? '' ),
        'relationship' => sanitize_text_field( $_POST['contact_relationship'] ?? '' ),
    );

    if ( empty( $new['name'] ) || empty( $new['phone'] ) ) {
        wp_send_json_error( array( 'message' => __( 'Nome e telefono obbligatori.', 'sd-logbook' ) ) );
    }

    $edit_index = isset( $_POST['edit_index'] ) && '' !== $_POST['edit_index'] ? absint( $_POST['edit_index'] ) : -1;
    if ( $edit_index >= 0 && isset( $contacts[ $edit_index ] ) ) {
        $contacts[ $edit_index ] = $new;
    } else {
        $contacts[] = $new;
    }

    update_user_meta( $user_id, 'sd_emergency_contacts', $contacts );
    wp_send_json_success( array( 'message' => __( 'Contatto salvato.', 'sd-logbook' ) ) );
}
```

#### DOPO (codice corretto):
```php
public function save_emergency_contact() {
    check_ajax_referer( 'sd_profile_nonce', 'nonce' );
    $user_id  = get_current_user_id();
    $contacts = get_user_meta( $user_id, 'sd_emergency_contacts', true ) ?: array();

    $new = array(
        'name'         => sanitize_text_field( $_POST['contact_name'] ?? '' ),
        'phone'        => sanitize_text_field( $_POST['contact_phone'] ?? '' ),
        'relationship' => sanitize_text_field( $_POST['contact_relationship'] ?? '' ),
        'email'        => sanitize_email( $_POST['contact_email'] ?? '' ),        // 🆕 AGGIUNTO
        'notes'        => sanitize_textarea_field( $_POST['contact_notes'] ?? '' ), // 🆕 AGGIUNTO
    );

    if ( empty( $new['name'] ) || empty( $new['phone'] ) ) {
        wp_send_json_error( array( 'message' => __( 'Nome e telefono obbligatori.', 'sd-logbook' ) ) );
    }

    $edit_index = isset( $_POST['edit_index'] ) && '' !== $_POST['edit_index'] ? absint( $_POST['edit_index'] ) : -1;
    if ( $edit_index >= 0 && isset( $contacts[ $edit_index ] ) ) {
        $contacts[ $edit_index ] = $new;
    } else {
        $contacts[] = $new;
    }

    update_user_meta( $user_id, 'sd_emergency_contacts', $contacts );
    wp_send_json_success( array( 'message' => __( 'Contatto salvato.', 'sd-logbook' ) ) );
}
```

---

## Verifica della Soluzione

### 1. Verifica Backend (WordPress Web Interface)

Se hai un template che mostra i contatti di emergenza nella web interface, assicurati che mostri anche email e notes:

```php
<?php foreach ( $emergency_contacts as $index => $contact ): ?>
    <div class="contact-item">
        <strong><?php echo esc_html( $contact['name'] ); ?></strong>
        <div><?php echo esc_html( $contact['phone'] ); ?></div>
        <?php if ( ! empty( $contact['relationship'] ) ): ?>
            <div class="text-muted"><?php echo esc_html( $contact['relationship'] ); ?></div>
        <?php endif; ?>
        <?php if ( ! empty( $contact['email'] ) ): ?>
            <div class="text-danger">
                <i class="fas fa-envelope"></i>
                <a href="mailto:<?php echo esc_attr( $contact['email'] ); ?>">
                    <?php echo esc_html( $contact['email'] ); ?>
                </a>
            </div>
        <?php endif; ?>
        <?php if ( ! empty( $contact['notes'] ) ): ?>
            <div class="text-muted"><small><?php echo esc_html( $contact['notes'] ); ?></small></div>
        <?php endif; ?>
    </div>
<?php endforeach; ?>
```

### 2. Test con l'App iOS

Dopo aver applicato la modifica al backend:

1. Apri l'app iOS
2. Vai al Profilo → Contatti di Emergenza
3. Modifica il contatto esistente "Mirko Achermann"
4. Verifica che `relationship` sia precompilato con "Amico/a"
5. Verifica che `email` sia precompilato con "mirko.achermann@gmail.com"
6. Cambia la relazione in "Coniuge/Partner"
7. Salva
8. Chiudi l'app completamente (swipe up)
9. Riapri l'app
10. Verifica che i dati siano ancora presenti

### 3. Verifica Console Log

Nel debug dovresti ora vedere:
```
✅ [PROFILE] Caricato con successo
  📞 Emergency Contacts: 1
    - Mirko Achermann | +41796636610
      relationship: Coniuge/Partner  ✅
      email: mirko.achermann@gmail.com  ✅
```

---

## Endpoint API REST (se implementato)

Se stai usando l'API REST di WordPress invece degli handler AJAX, assicurati che:

### GET `/wp-json/sd/v1/profile/emergency-contacts`

Risposta:
```json
[
  {
    "id": 1,
    "name": "Mirko Achermann",
    "phone": "+41796636610",
    "relationship": "Amico/a",
    "email": "mirko.achermann@gmail.com",
    "notes": ""
  }
]
```

### POST/PUT `/wp-json/sd/v1/profile/emergency-contacts`

Request Body accettato:
```json
{
  "name": "Mirko Achermann",
  "phone": "+41796636610",
  "relationship": "Coniuge/Partner",
  "email": "mirko.achermann@gmail.com",
  "notes": "Contatto principale"
}
```

---

## Note per i Dati Esistenti

I contatti di emergenza già salvati nel database **NON avranno** i campi `email` e `notes`. Questo è normale e l'app iOS lo gestisce correttamente mostrando campi vuoti.

Gli utenti dovranno:
1. Modificare i contatti esistenti
2. Aggiungere email e notes
3. Salvare nuovamente

Dopo questa operazione, i dati saranno completi.

---

## Checklist Finale

- [ ] Modificato `class-sd-diver-profile.php` → funzione `save_emergency_contact()`
- [ ] Aggiunto campo `email` con `sanitize_email()`
- [ ] Aggiunto campo `notes` con `sanitize_textarea_field()`
- [ ] Testato salvataggio da web interface (se presente)
- [ ] Testato salvataggio da app iOS
- [ ] Verificato che i dati persistano dopo riavvio app
- [ ] Verificato console log con dati completi

---

## Supporto

Se dopo aver applicato questa modifica i dati non vengono ancora salvati:

1. Controlla il formato della request dall'app iOS (Network tab in Xcode)
2. Verifica che i nomi dei parametri corrispondano: `contact_email` e `contact_notes`
3. Controlla i log PHP per eventuali errori di sanitizzazione
4. Verifica che `user_meta` venga effettivamente aggiornato nel database WordPress
