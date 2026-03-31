// raptor-cube-model.js - Велоцираптор из кубов и прямоугольников
import * as THREE from 'three';

export function createRaptor() {
    const group = new THREE.Group();
    
    // Цвета
    const bodyColor = 0x6a8a5a;        // Зелёный
    const bellyColor = 0xbdae7a;        // Бежевый
    const darkColor = 0x4a6a3a;         // Тёмно-зелёный
    const eyeColor = 0xffaa44;          // Жёлтый
    const clawColor = 0xaa8866;         // Когти
    const spikeColor = 0x8a6a4a;        // Шипы
    
    // Материалы
    const bodyMat = new THREE.MeshStandardMaterial({ color: bodyColor, roughness: 0.5 });
    const bellyMat = new THREE.MeshStandardMaterial({ color: bellyColor, roughness: 0.6 });
    const darkMat = new THREE.MeshStandardMaterial({ color: darkColor, roughness: 0.4 });
    const eyeMat = new THREE.MeshStandardMaterial({ color: eyeColor, emissive: 0x442200, emissiveIntensity: 0.2 });
    const clawMat = new THREE.MeshStandardMaterial({ color: clawColor, roughness: 0.3 });
    const spikeMat = new THREE.MeshStandardMaterial({ color: spikeColor, roughness: 0.4 });
    
    // ==================== ТЕЛО ====================
    // Основное тело (центральный куб)
    const body = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.7, 1.4), bodyMat);
    body.position.set(0, 0.2, 0);
    body.castShadow = true;
    body.receiveShadow = true;
    group.add(body);
    
    // Грудная клетка (верхняя часть)
    const chest = new THREE.Mesh(new THREE.BoxGeometry(0.8, 0.6, 0.8), bodyMat);
    chest.position.set(0, 0.45, 0.55);
    chest.castShadow = true;
    group.add(chest);
    
    // Живот (светлый)
    const belly = new THREE.Mesh(new THREE.BoxGeometry(0.75, 0.4, 1.1), bellyMat);
    belly.position.set(0, -0.1, 0.25);
    belly.castShadow = true;
    group.add(belly);
    
    // Спина (тёмная)
    const back = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.3, 1.0), darkMat);
    back.position.set(0, 0.55, -0.2);
    back.castShadow = true;
    group.add(back);
    
    // ==================== ШЕЯ ====================
    // Нижняя часть шеи
    const neckLower = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.5, 0.6), bodyMat);
    neckLower.position.set(0, 0.7, 0.65);
    neckLower.castShadow = true;
    group.add(neckLower);
    
    // Верхняя часть шеи
    const neckUpper = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.45, 0.55), bodyMat);
    neckUpper.position.set(0, 1.0, 0.9);
    neckUpper.castShadow = true;
    group.add(neckUpper);
    
    // ==================== ГОЛОВА ====================
    // Основа головы
    const head = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.55, 0.65), bodyMat);
    head.position.set(0, 1.25, 1.15);
    head.castShadow = true;
    group.add(head);
    
    // Морда (верхняя челюсть)
    const snout = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.3, 0.7), bodyMat);
    snout.position.set(0, 1.28, 1.55);
    snout.castShadow = true;
    group.add(snout);
    
    // Нижняя челюсть
    const jaw = new THREE.Mesh(new THREE.BoxGeometry(0.44, 0.22, 0.65), bellyMat);
    jaw.position.set(0, 1.05, 1.52);
    jaw.castShadow = true;
    group.add(jaw);
    
    // Кончик морды
    const snoutTip = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.25, 0.35), darkMat);
    snoutTip.position.set(0, 1.27, 1.92);
    snoutTip.castShadow = true;
    group.add(snoutTip);
    
    // ==================== ГЛАЗА ====================
    // Левый глаз
    const eyeL = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), eyeMat);
    eyeL.position.set(-0.2, 1.35, 1.35);
    group.add(eyeL);
    
    // Правый глаз
    const eyeR = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), eyeMat);
    eyeR.position.set(-2.2, 1.35, 1.35);
    group.add(eyeR);
    
    // Зрачки (маленькие чёрные сферы)
    const pupilMat = new THREE.MeshStandardMaterial({ color: 0x000000 });
    const pupilL = new THREE.Mesh(new THREE.SphereGeometry(0.05, 16, 16), pupilMat);
    pupilL.position.set(-0.2, 1.34, 1.45);
    group.add(pupilL);
    
    const pupilR = new THREE.Mesh(new THREE.SphereGeometry(0.05, 16, 16), pupilMat);
    pupilR.position.set(0.2, 1.34, 1.45);
    group.add(pupilR);
    
    // ==================== ГРЕБЕНЬ НА ГОЛОВЕ ====================
    const crestPositions = [
        [0, 1.48, 1.28], [0.1, 1.45, 1.24], [-0.1, 1.45, 1.24],
        [0, 1.4, 1.2], [0.08, 1.38, 1.16], [-0.08, 1.38, 1.16]
    ];
    
    crestPositions.forEach(pos => {
        const crest = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.12, 0.1), spikeMat);
        crest.position.set(pos[0], pos[1], pos[2]);
        crest.castShadow = true;
        group.add(crest);
    });
    
    // ==================== ПЕРЕДНИЕ ЛАПЫ ====================
    // Левое плечо
    const shoulderL = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.28, 0.28), bodyMat);
    shoulderL.position.set(-0.55, 0.65, 0.7);
    shoulderL.castShadow = true;
    group.add(shoulderL);
    
    // Левое предплечье
    const armL = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.22, 0.45), bodyMat);
    armL.position.set(-0.85, 0.62, 0.85);
    armL.rotation.z = -0.3;
    armL.castShadow = true;
    group.add(armL);
    
    // Левая лапа
    const pawL = new THREE.Mesh(new THREE.BoxGeometry(0.25, 0.18, 0.28), bodyMat);
    pawL.position.set(-1.05, 0.55, 0.95);
    pawL.castShadow = true;
    group.add(pawL);
    
    // Правое плечо
    const shoulderR = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.28, 0.28), bodyMat);
    shoulderR.position.set(0.55, 0.65, 0.7);
    shoulderR.castShadow = true;
    group.add(shoulderR);
    
    // Правое предплечье
    const armR = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.22, 0.45), bodyMat);
    armR.position.set(0.85, 0.62, 0.85);
    armR.rotation.z = 0.3;
    armR.castShadow = true;
    group.add(armR);
    
    // Правая лапа
    const pawR = new THREE.Mesh(new THREE.BoxGeometry(0.25, 0.18, 0.28), bodyMat);
    pawR.position.set(1.05, 0.55, 0.95);
    pawR.castShadow = true;
    group.add(pawR);
    
    // Когти на передних лапах (маленькие кубики)
    const smallClawGeo = new THREE.BoxGeometry(0.07, 0.07, 0.12);
    const clawPosFront = [
        [-1.1, 0.5, 1.02], [-1.02, 0.5, 1.05], [-1.06, 0.48, 0.98],
        [1.1, 0.5, 1.02], [1.02, 0.5, 1.05], [1.06, 0.48, 0.98]
    ];
    
    clawPosFront.forEach(pos => {
        const claw = new THREE.Mesh(smallClawGeo, clawMat);
        claw.position.set(pos[0], pos[1], pos[2]);
        claw.castShadow = true;
        group.add(claw);
    });
    
    // ==================== ЗАДНИЕ НОГИ ====================
    // Левое бедро
    const thighL = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.45, 0.55), bodyMat);
    thighL.position.set(-0.55, 0.25, -0.5);
    thighL.castShadow = true;
    group.add(thighL);
    
    // Левая голень
    const shinL = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.45, 0.48), bodyMat);
    shinL.position.set(-0.62, -0.1, -0.75);
    shinL.castShadow = true;
    group.add(shinL);
    
    // Левая ступня
    const footL = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.2, 0.55), bodyMat);
    footL.position.set(-0.65, -0.45, -0.95);
    footL.castShadow = true;
    group.add(footL);
    
    // Правое бедро
    const thighR = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.45, 0.55), bodyMat);
    thighR.position.set(0.55, 0.25, -0.5);
    thighR.castShadow = true;
    group.add(thighR);
    
    // Правая голень
    const shinR = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.45, 0.48), bodyMat);
    shinR.position.set(0.62, -0.1, -0.75);
    shinR.castShadow = true;
    group.add(shinR);
    
    // Правая ступня
    const footR = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.2, 0.55), bodyMat);
    footR.position.set(0.65, -0.45, -0.95);
    footR.castShadow = true;
    group.add(footR);
    
    // ==================== СЕРПОВИДНЫЕ КОГТИ ====================
    // Левый серповидный коготь (удлинённый куб)
    const sickleL = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.08, 0.35), clawMat);
    sickleL.position.set(-0.72, -0.42, -1.02);
    sickleL.rotation.z = -0.3;
    sickleL.castShadow = true;
    group.add(sickleL);
    
    // Правый серповидный коготь
    const sickleR = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.08, 0.35), clawMat);
    sickleR.position.set(0.72, -0.42, -1.02);
    sickleR.rotation.z = 0.3;
    sickleR.castShadow = true;
    group.add(sickleR);
    
    // Остальные когти
    const toeClawGeo = new THREE.BoxGeometry(0.09, 0.09, 0.18);
    const toePositions = [
        [-0.58, -0.48, -0.92], [-0.68, -0.5, -0.88], [-0.62, -0.52, -0.82],
        [0.58, -0.48, -0.92], [0.68, -0.5, -0.88], [0.62, -0.52, -0.82]
    ];
    
    toePositions.forEach(pos => {
        const claw = new THREE.Mesh(toeClawGeo, clawMat);
        claw.position.set(pos[0], pos[1], pos[2]);
        claw.castShadow = true;
        group.add(claw);
    });
    
    // ==================== ХВОСТ ====================
    // Основание хвоста
    const tailBase = new THREE.Mesh(new THREE.BoxGeometry(0.4, 0.35, 0.7), bodyMat);
    tailBase.position.set(0, 0.12, -1.05);
    tailBase.castShadow = true;
    group.add(tailBase);
    
    // Средняя часть хвоста
    const tailMid = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.28, 0.85), bodyMat);
    tailMid.position.set(0, 0.02, -1.65);
    tailMid.castShadow = true;
    group.add(tailMid);
    
    // Дальняя часть хвоста
    const tailFar = new THREE.Mesh(new THREE.BoxGeometry(0.24, 0.22, 0.8), bodyMat);
    tailFar.position.set(0, -0.05, -2.25);
    tailFar.castShadow = true;
    group.add(tailFar);
    
    // Кончик хвоста
    const tailTip = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.16, 0.55), darkMat);
    tailTip.position.set(0, -0.1, -2.75);
    tailTip.castShadow = true;
    group.add(tailTip);
    
    // ==================== ШИПЫ НА СПИНЕ ====================
    const spineSpikeGeo = new THREE.BoxGeometry(0.1, 0.18, 0.1);
    const spinePositions = [
        [0, 0.68, -0.05], [0, 0.7, 0.15], [0, 0.68, 0.35], 
        [0, 0.62, 0.55], [0, 0.55, 0.72], [0, 0.45, 0.88],
        [0, 0.38, -0.35], [0, 0.32, -0.65], [0, 0.25, -0.95]
    ];
    
    spinePositions.forEach(pos => {
        const spike = new THREE.Mesh(spineSpikeGeo, spikeMat);
        spike.position.set(pos[0], pos[1], pos[2]);
        spike.castShadow = true;
        group.add(spike);
    });
    
    // ==================== ПЯТНА НА КОЖЕ ====================
    const spotMat = new THREE.MeshStandardMaterial({ color: 0x4a6a3a });
    const spotPositions = [
        [-0.45, 0.45, 0.35], [0.45, 0.45, 0.35], [-0.38, 0.52, 0.12], 
        [0.38, 0.52, 0.12], [-0.42, 0.4, -0.25], [0.42, 0.4, -0.25],
        [-0.35, 0.32, -0.65], [0.35, 0.32, -0.65]
    ];
    
    spotPositions.forEach(pos => {
        const spot = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.05, 0.12), spotMat);
        spot.position.set(pos[0], pos[1], pos[2]);
        spot.castShadow = true;
        group.add(spot);
    });
    
    return group;
}