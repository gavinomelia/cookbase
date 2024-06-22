document.addEventListener('DOMContentLoaded', function() {
    // Event delegation for dynamically added elements
    document.addEventListener('click', function(event) {
        if (event.target.matches('.remove_ingredient')) {
            event.preventDefault();
            let field = event.target.closest('.ingredient-fields');
            field.querySelector('input[name*="_destroy"]').value = '1';
            field.style.display = 'none';
        } else if (event.target.matches('#add_ingredient')) {
            event.preventDefault();
            let time = new Date().getTime();
            let template = document.querySelector('#ingredient_template').innerHTML;
            template = template.replace(/NEW_RECORD/g, time);
            document.querySelector('#ingredients').insertAdjacentHTML('beforeend', template);
        }
    });
});

function removeFields(event) {
    event.preventDefault();
    let field = event.target.closest('.ingredient-fields');
    field.querySelector('input[name*="_destroy"]').value = '1';
    field.style.display = 'none';
}

function addFields(event) {
    event.preventDefault();
    let time = new Date().getTime();
    let template = document.querySelector('#ingredient_template').innerHTML;
    template = template.replace(/NEW_RECORD/g, time);
    document.querySelector('#ingredients').insertAdjacentHTML('beforeend', template);

    // Add event listener to the new remove link
    let newField = document.querySelector('#ingredients').lastElementChild;
    newField.querySelector('.remove_ingredient').addEventListener('click', removeFields);
}

