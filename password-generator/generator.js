function generate(){
    let dictionary= '';
    if (document.getElementById('lowercaseCb').checked) {
        dictionary += 'abcdefghijklmnopqrstuvwxyz';
    }
    if (document.getElementById('uppercaseCb').checked) {
        dictionary += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (document.getElementById('digitsCb').checked) {
        dictionary += '0123456789';
    }
    if (document.getElementById('specialsCb').checked) {
        dictionary += '!@#$%^&*()_+-={}[];<>:';
    }
    const length = document.querySelector('input[type="range"]').value; 
    if (length < 1 || dictionary.length === 1) {
        return;
    }
    let password = '';
    for (let i = 0; i < length; i++) {
        const pos = Math.floor(Math.random() * dictionary.length); 
        password += dictionary[pos];
    }
    document.querySelector('input[type="text"]').value = password;
}
[...document.querySelectorAll('input[type="checkbox"], button.generate')].forEach(element => {
    element.addEventListener('click', generate);
})
document.querySelector('input[type="range"]').addEventListener('input', e => {
    generate();
    document.querySelector('div.range span').innerHTML = e.target.value;
});
document.querySelector('div.password button').addEventListener('click', e => {
    const pass = document.querySelector('input[type="text"]').value;
    navigator.clipboard.writeText(pass).then( () => {
        document.querySelector('div.password button').innerHTML = 'Copied!';
        setTimeout(() => {
            document.querySelector('div.password button').innerHTML = 'Copy';
        }, 1000);
    })
});
generate();
